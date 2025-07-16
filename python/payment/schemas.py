from pydantic import BaseModel

class PaymentCreate(BaseModel):
    order_id: int
    amount: float
    method: str

class PaymentRead(PaymentCreate):
    id: int
    status: str

    class Config:
        orm_mode = True
