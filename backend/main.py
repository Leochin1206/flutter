from fastapi import FastAPI, HTTPException
from sqlmodel import SQLModel, Field, create_engine, Session, select
from typing import List, Optional
from datetime import datetime, timedelta
import random

sqlite_file_name = "database.db"
sqlite_url = f"sqlite:///{sqlite_file_name}"
engine = create_engine(sqlite_url, connect_args={"check_same_thread": False})
app = FastAPI()

class Sensor(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    localSensor: str
    tipo: str
    macAddress: Optional[str] = None
    latitude: float
    longitude: float
    responsavel: str
    observacao: Optional[str] = None
    status_operacional: int = Field(default=1)  

class FiltroTemperatura(SQLModel):
    sensor_id: int
    de: Optional[str] = None
    ate: Optional[str] = None

@app.on_event("startup")
def on_startup():
    SQLModel.metadata.create_all(engine)

@app.get("/sensores/", response_model=List[Sensor])
def listar_sensores():
    with Session(engine) as session:
        sensores = session.exec(select(Sensor)).all()
        return sensores

@app.post("/sensores/", response_model=Sensor)
def cadastrar_sensor(sensor: Sensor):
    with Session(engine) as session:
        session.add(sensor)
        session.commit()
        session.refresh(sensor) 
        return sensor

@app.put("/sensores/{sensor_id}")
def atualizar_sensor(sensor_id: int, sensor_atualizado: Sensor):
    with Session(engine) as session:
        sensor_db = session.get(Sensor, sensor_id)
        
        if not sensor_db:
            raise HTTPException(status_code=404, detail="Sensor não encontrado")
        
        sensor_data = sensor_atualizado.dict(exclude_unset=True)
        for key, value in sensor_data.items():
            if key != 'id': 
                setattr(sensor_db, key, value)
        
        session.add(sensor_db)
        session.commit()
        session.refresh(sensor_db)
        return {"mensagem": "Sensor atualizado!", "sensor": sensor_db}

@app.post("/temperaturas/")
def pegar_temperaturas(filtro: FiltroTemperatura):
    dados_simulados = []
    agora = datetime.now()

    for i in range(15):
        tempo = agora - timedelta(minutes=i*30)
        valor_aleatorio = random.uniform(20.0, 35.0)
        
        dados_simulados.append({
            "sensor_id": filtro.sensor_id,
            "valor": round(valor_aleatorio, 2),
            "timestamp": tempo.isoformat()
        })
        
    return list(reversed(dados_simulados))