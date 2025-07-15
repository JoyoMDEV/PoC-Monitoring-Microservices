import logging
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from prometheus_fastapi_instrumentator import Instrumentator

from database import SessionLocal, engine
from models import Base, Payment
from schemas import PaymentCreate, PaymentRead

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
    return {"message": "Payment Service online"}

@app.post("/payments", response_model=PaymentRead)
def create_payment(payment: PaymentCreate, db: Session = Depends(get_db)):
    try:
        db_payment = Payment(
            order_id=payment.order_id,
            amount=payment.amount,
            method=payment.method
        )
        db.add(db_payment)
        db.commit()
        db.refresh(db_payment)
        logger.info("payment_created", order_id=payment.order_id, amount=payment.amount, method=payment.method)
        return db_payment
    except SQLAlchemyError as e:
        logger.error("db_error_create_payment", error=str(e))
        raise HTTPException(status_code=500, detail="Database error")

@app.get("/payments/{payment_id}", response_model=PaymentRead)
def get_payment(payment_id: int, db: Session = Depends(get_db)):
    try:
        payment = db.query(Payment).filter(Payment.id == payment_id).first()
        if not payment:
            logger.warning("payment_not_found", payment_id=payment_id)
            raise HTTPException(status_code=404, detail="Payment not found")
        logger.info("payment_retrieved", payment_id=payment_id)
        return payment
    except SQLAlchemyError as e:
        logger.error("db_error_get_payment", error=str(e), payment_id=payment_id)
        raise HTTPException(status_code=500, detail="Database error")
    except Exception as e:
        logger.error("unknown_error_get_payment", error=str(e), payment_id=payment_id)
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
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

def setup_tracing():
    provider = TracerProvider(resource=Resource.create({SERVICE_NAME: "payment-service"}))
    trace.set_tracer_provider(provider)
    otlp_exporter = OTLPSpanExporter(
        endpoint="nginx:80/jaeger/agent",
        insecure=True
    )
    span_processor = BatchSpanProcessor(otlp_exporter)
    provider.add_span_processor(span_processor)
    FastAPIInstrumentor.instrument_app(app)

setup_tracing()
