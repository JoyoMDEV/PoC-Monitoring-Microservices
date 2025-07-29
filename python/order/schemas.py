from pydantic import BaseModel

class OrderCreate(BaseModel):
    product_id: int
    quantity: int
    total_price: float

class OrderRead(OrderCreate):
    id: int
    status: str

    class Config:
        orm_mode = True
