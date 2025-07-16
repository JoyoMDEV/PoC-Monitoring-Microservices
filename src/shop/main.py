import logging
import structlog
import sys

from fastapi import FastAPI, HTTPException, Body
from prometheus_fastapi_instrumentator import Instrumentator

import httpx

# --- Logging & Structlog ---
structlog.configure(
    processors=[structlog.processors.JSONRenderer()],
    logger_factory=structlog.stdlib.LoggerFactory(),
)
logging.basicConfig(
    stream=sys.stdout,
    level=logging.INFO,
)
logger = structlog.get_logger()

app = FastAPI()

@app.get("/")
def read_root():
    logger.info("root_called")
    return {"message": "Shop Gateway online"}

@app.post("/shop/purchase")
async def shop_purchase(
    product_id: int = Body(...),
    quantity: int = Body(...),
    payment_method: str = Body("credit_card")
):
    try:
        async with httpx.AsyncClient() as client:
            # --- Schritt 1: Produktdaten holen ---
            prod_resp = await client.get(f"http://product:8000/products/{product_id}")
            if prod_resp.status_code != 200:
                logger.error("product_not_found", product_id=product_id)
                raise HTTPException(status_code=404, detail="Product not found")
            product = prod_resp.json()
            total_price = product["price"] * quantity
            logger.info("product_fetched", product_id=product_id, price=product["price"], quantity=quantity)

            # --- Schritt 2: Order anlegen ---
            order_data = {
                "product_id": product_id,
                "quantity": quantity,
                "total_price": total_price
            }
            order_resp = await client.post("http://order:8000/orders", json=order_data)
            if order_resp.status_code not in (200, 201):
                logger.error("order_failed", reason=order_resp.text)
                raise HTTPException(status_code=400, detail="Order creation failed")
            order = order_resp.json()
            logger.info("order_created", order_id=order["id"], total_price=total_price)

            # --- Schritt 3: Payment auslösen ---
            payment_data = {
                "order_id": order["id"],
                "amount": total_price,
                "method": payment_method
            }
            payment_resp = await client.post("http://payment:8000/payments", json=payment_data)
            if payment_resp.status_code not in (200, 201):
                logger.error("payment_failed", reason=payment_resp.text)
                raise HTTPException(status_code=400, detail="Payment failed")
            payment = payment_resp.json()
            logger.info("payment_success", payment_id=payment["id"], amount=payment["amount"])

        return {
            "order": order,
            "payment": payment,
            "product": product
        }
    except Exception as e:
        logger.error("shop_purchase_failed", error=str(e))
        raise HTTPException(status_code=500, detail="Shop purchase failed")

# --- Prometheus Metrics ---
Instrumentator().instrument(app).expose(app)

# --- Jaeger/OpenTelemetry ---
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.httpx import HTTPXClientInstrumentor
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

def setup_tracing():
    provider = TracerProvider(resource=Resource.create({SERVICE_NAME: "shop-service"}))
    trace.set_tracer_provider(provider)
    otlp_exporter = OTLPSpanExporter(
        endpoint="traefik:4317",
        insecure=True
    )
    span_processor = BatchSpanProcessor(otlp_exporter)
    provider.add_span_processor(span_processor)
    FastAPIInstrumentor.instrument_app(app)
    HTTPXClientInstrumentor().instrument()   # <- Das macht httpx-Traces sichtbar!

setup_tracing()
