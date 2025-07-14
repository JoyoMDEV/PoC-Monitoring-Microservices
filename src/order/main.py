import logging
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from prometheus_fastapi_instrumentator import Instrumentator

from database import SessionLocal, engine
from models import Base, Order
from schemas import OrderCreate, OrderRead

import structlog
import sys

structlog.configure(
    processors=[
        structlog.processors.JSONRenderer(),
    ],
    logger_factory=structlog.stdlib.LoggerFactory(),
)
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
)
logger = structlog.get_logger()

# DB Initialisierung
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Dependency für DB-Session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def read_root():
    logger.info("root called")
    return {"message": "Order Service online"}

@app.post("/orders", response_model=OrderRead)
def create_order(order: OrderCreate, db: Session = Depends(get_db)):
    try:
        db_order = Order(
            product_id=order.product_id,
            quantity=order.quantity,
            total_price=order.total_price
        )
        db.add(db_order)
        db.commit()
        db.refresh(db_order)
        logger.info("order_created", product_id=order.product_id, quantity=order.quantity, total_price=order.total_price)
        return db_order
    except SQLAlchemyError as e:
        logger.error("db_error_create_order", error=str(e))
        raise HTTPException(status_code=500, detail="Database error")

@app.get("/orders/{order_id}", response_model=OrderRead)
def get_order(order_id: int, db: Session = Depends(get_db)):
    try:
        order = db.query(Order).filter(Order.id == order_id).first()
        if not order:
            logger.warning("order_not_found", order_id=order_id)
            raise HTTPException(status_code=404, detail="Order not found")
        logger.info("order_retrieved", order_id=order_id)
        return order
    except SQLAlchemyError as e:
        logger.error("db_error_get_order", error=str(e), order_id=order_id)
        raise HTTPException(status_code=500, detail="Database error")
    except Exception as e:
        logger.error("unknown_error_get_order", error=str(e), order_id=order_id)
        raise HTTPException(status_code=500, detail="Unknown server error")

@app.get("/health", status_code=status.HTTP_200_OK)
def healthcheck(db: Session = Depends(get_db)):
    try:
        db.execute(text("SELECT 1"))
        logger.info("healthcheck_success")
        return {"status": "ok"}
    except Exception as e:
        logger.error("healthcheck_failed", error=str(e))
        raise HTTPException(status_code=503, detail="Service unhealthy")


# Prometheus Metrics
Instrumentator().instrument(app).expose(app)

# OpenTelemetry Jaeger Tracing
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

def setup_tracing():
    provider = TracerProvider(resource=Resource.create({SERVICE_NAME: "order-service"}))
    trace.set_tracer_provider(provider)
    jaeger_exporter = JaegerExporter(
        agent_host_name="jaeger",
        agent_port=6831,
    )
    span_processor = BatchSpanProcessor(jaeger_exporter)
    provider.add_span_processor(span_processor)
    FastAPIInstrumentor.instrument_app(app)

setup_tracing()
