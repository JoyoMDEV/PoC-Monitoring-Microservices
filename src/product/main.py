import logging
from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy.exc import SQLAlchemyError
from prometheus_fastapi_instrumentator import Instrumentator

from database import SessionLocal, engine
from models import Base, Product
from schemas import ProductCreate, ProductRead

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
    return {"message": "Product Service online"}

@app.post("/products", response_model=ProductRead)
def create_product(product: ProductCreate, db: Session = Depends(get_db)):
    try:
        db_product = Product(name=product.name, price=product.price)
        db.add(db_product)
        db.commit()
        db.refresh(db_product)
        logger.info("product_created", name=product.name, price=product.price)
        return db_product
    except SQLAlchemyError as e:
        logger.error("db_error", error=str(e))
        raise HTTPException(status_code=500, detail="Database error")

from sqlalchemy.exc import SQLAlchemyError

@app.get("/products/{product_id}", response_model=ProductRead)
def get_product(product_id: int, db: Session = Depends(get_db)):
    try:
        product = db.query(Product).filter(Product.id == product_id).first()
        if not product:
            logger.warning("product_not_found", product_id=product_id)
            raise HTTPException(status_code=404, detail="Product not found")
        logger.info("product_retrieved", product_id=product_id)
        return product
    except SQLAlchemyError as e:
        logger.error("db_error_get_product", error=str(e), product_id=product_id)
        raise HTTPException(status_code=500, detail="Database error")
    except Exception as e:
        logger.error("unknown_error_get_product", error=str(e), product_id=product_id)
        raise HTTPException(status_code=500, detail="Unknown server error")


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
    provider = TracerProvider(resource=Resource.create({SERVICE_NAME: "product-service"}))
    trace.set_tracer_provider(provider)
    jaeger_exporter = JaegerExporter(
        agent_host_name="jaeger",
        agent_port=6831,
    )
    span_processor = BatchSpanProcessor(jaeger_exporter)
    provider.add_span_processor(span_processor)
    FastAPIInstrumentor.instrument_app(app)

setup_tracing()
