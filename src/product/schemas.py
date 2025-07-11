from pydantic import BaseModel

class ProductCreate(BaseModel):
    name: str
    price: float

class ProductRead(ProductCreate):
    id: int

    class Config:
        orm_mode = True
