from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd


app = FastAPI()


# CORS para permitir peticiones desde Flutter (localhost, web, etc.)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

import os

if not os.path.exists("HR-Employee-Attrition.csv"):
    raise FileNotFoundError("🚨 CSV no encontrado en la carpeta del backend")

# Cargar los datos del CSV
df = pd.read_csv("HR-Employee-Attrition.csv")
df['EmployeeNumber'] = df['EmployeeNumber'].astype(str)  # Para facilitar búsquedas


@app.get("/")
def root():
    return {"message": "API de Empleados activa"}


@app.get("/employees")
def get_employees(skip: int = 0, limit: int = 50):
    return df.iloc[skip:skip+limit].to_dict(orient="records")


@app.get("/employees/{employee_id}")
def get_employee(employee_id: str):
    employee = df[df["EmployeeNumber"] == employee_id]
    if employee.empty:
        raise HTTPException(status_code=404, detail="Empleado no encontrado")
    return employee.iloc[0].to_dict()


@app.get("/stats")
def get_stats():
    total = len(df)
    attrition = len(df[df["Attrition"] == "Yes"])
    avg_performance = df["PerformanceRating"].mean()
    avg_satisfaction = df["JobSatisfaction"].mean()


    return {
        "total_employees": total,
        "attrition_rate": round(attrition / total, 2),
        "avg_performance": round(avg_performance, 2),
        "avg_satisfaction": round(avg_satisfaction, 2),
    }


@app.get("/alerts")
def get_alerts():
    # Simular alertas si el rendimiento es bajo o el balance vida-trabajo es muy bajo
    low_perf = df[df["PerformanceRating"] <= 2]
    low_balance = df[df["WorkLifeBalance"] <= 2]
    overtime = df[df["OverTime"] == "Yes"]


    alert_employees = pd.concat([low_perf, low_balance, overtime]).drop_duplicates()
    return alert_employees[["EmployeeNumber", "JobRole", "PerformanceRating", "WorkLifeBalance", "OverTime"]].to_dict(orient="records")

from fastapi import Body

@app.post("/employees")
def add_employee(employee: dict = Body(...)):
    global df
    df = pd.concat([df, pd.DataFrame([employee])], ignore_index=True)
    df.to_csv("HR-Employee-Attrition.csv", index=False)
    return {"message": "Empleado añadido con éxito"}
