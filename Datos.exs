defmodule Datos do

  def repartidores do
    [
      %{codigo: "M01", nombre: "Laura Gómez",        bicicleta: true},
      %{codigo: "M02", nombre: "Carlos Ruiz",         bicicleta: false},
      %{codigo: "M03", nombre: "María Pérez",         bicicleta: true},
      %{codigo: "M04", nombre: "Andrés Mora",         bicicleta: false},
      %{codigo: "M05", nombre: "Juliana Castro",      bicicleta: true},
      %{codigo: "M06", nombre: "Felipe Torres",       bicicleta: false},
      %{codigo: "M07", nombre: "Valentina Díaz",      bicicleta: true},
      %{codigo: "M08", nombre: "Sebastián Vargas",    bicicleta: false},
      %{codigo: "M09", nombre: "Daniela Herrera",     bicicleta: false},
      %{codigo: "M10", nombre: "Camilo Ospina",       bicicleta: false}
    ]
  end

  # ============================================================
  # ZONAS
  # Exactamente 4 zonas con sus áreas en km²
  # ============================================================
  @doc """
  Lista de zonas de cobertura de la empresa.
  """
  def zonas do
    [
      %{id: "Z1", nombre: "Centro",   area: 6.5},
      %{id: "Z2", nombre: "Norte",    area: 10.2},
      %{id: "Z3", nombre: "Sur",      area: 8.0},
      %{id: "Z4", nombre: "Oriente",  area: 12.5}
    ]
  end

  # ============================================================
  # SERVICIOS
  # 85 servicios válidos y 10 inválidos
  # ============================================================
  @doc """
  Lista de servicios registrados durante la semana (válidos e inválidos).
  """
  def servicios do
    [
      # ----------------------------------------------------------
      # DÍA 1 — 14 servicios válidos
      # M01: 22+18+25+20 = 85 km  → BONIFICACIÓN
      # M03: 40+42       = 82 km  → BONIFICACIÓN
      # ----------------------------------------------------------
      %{repartidor: "M01", zona: "Z1", dia: 1, kilometros: 22,   retraso: -5},
      %{repartidor: "M01", zona: "Z2", dia: 1, kilometros: 18,   retraso: 3},
      %{repartidor: "M01", zona: "Z3", dia: 1, kilometros: 25,   retraso: -2},
      %{repartidor: "M01", zona: "Z4", dia: 1, kilometros: 20,   retraso: 8},
      %{repartidor: "M02", zona: "Z1", dia: 1, kilometros: 30,   retraso: 0},
      %{repartidor: "M02", zona: "Z2", dia: 1, kilometros: 35,   retraso: 15},
      %{repartidor: "M03", zona: "Z1", dia: 1, kilometros: 40,   retraso: 35},
      %{repartidor: "M03", zona: "Z3", dia: 1, kilometros: 42,   retraso: -10},
      %{repartidor: "M04", zona: "Z2", dia: 1, kilometros: 28,   retraso: 5},
      %{repartidor: "M04", zona: "Z4", dia: 1, kilometros: 32,   retraso: 20},
      %{repartidor: "M05", zona: "Z1", dia: 1, kilometros: 20,   retraso: -15},
      %{repartidor: "M05", zona: "Z2", dia: 1, kilometros: 25,   retraso: 25},
      %{repartidor: "M06", zona: "Z3", dia: 1, kilometros: 18,   retraso: 0},
      %{repartidor: "M06", zona: "Z4", dia: 1, kilometros: 22,   retraso: 10},

      # ----------------------------------------------------------
      # DÍA 2 — 14 servicios válidos
      # M01: 42+40 = 82 km  → BONIFICACIÓN
      # M07: 35+28+20 = 83 km → BONIFICACIÓN
      # ----------------------------------------------------------
      %{repartidor: "M01", zona: "Z2", dia: 2, kilometros: 42,   retraso: -3},
      %{repartidor: "M01", zona: "Z4", dia: 2, kilometros: 40,   retraso: 7},
      %{repartidor: "M02", zona: "Z3", dia: 2, kilometros: 22,   retraso: 15},
      %{repartidor: "M02", zona: "Z1", dia: 2, kilometros: 28,   retraso: -5},
      %{repartidor: "M04", zona: "Z3", dia: 2, kilometros: 20,   retraso: 8},
      %{repartidor: "M07", zona: "Z1", dia: 2, kilometros: 35,   retraso: -8},
      %{repartidor: "M07", zona: "Z2", dia: 2, kilometros: 28,   retraso: 5},
      %{repartidor: "M07", zona: "Z3", dia: 2, kilometros: 20,   retraso: 25},
      %{repartidor: "M08", zona: "Z2", dia: 2, kilometros: 30,   retraso: 0},
      %{repartidor: "M08", zona: "Z4", dia: 2, kilometros: 38,   retraso: 12},
      %{repartidor: "M09", zona: "Z1", dia: 2, kilometros: 15,   retraso: -20},
      %{repartidor: "M09", zona: "Z3", dia: 2, kilometros: 18,   retraso: 3},
      %{repartidor: "M10", zona: "Z2", dia: 2, kilometros: 25,   retraso: 40},
      %{repartidor: "M10", zona: "Z4", dia: 2, kilometros: 30,   retraso: 180},

      # ----------------------------------------------------------
      # DÍA 3 — 14 servicios válidos
      # M03: 35+45 = 80 km exacto → BONIFICACIÓN
      # ----------------------------------------------------------
      %{repartidor: "M03", zona: "Z2", dia: 3, kilometros: 35,   retraso: 0},
      %{repartidor: "M03", zona: "Z4", dia: 3, kilometros: 45,   retraso: -5},
      %{repartidor: "M05", zona: "Z1", dia: 3, kilometros: 30,   retraso: 20},
      %{repartidor: "M05", zona: "Z3", dia: 3, kilometros: 35,   retraso: -8},
      %{repartidor: "M06", zona: "Z2", dia: 3, kilometros: 25,   retraso: 5},
      %{repartidor: "M06", zona: "Z4", dia: 3, kilometros: 28,   retraso: 30},
      %{repartidor: "M07", zona: "Z1", dia: 3, kilometros: 22,   retraso: -12},
      %{repartidor: "M07", zona: "Z4", dia: 3, kilometros: 30,   retraso: 8},
      %{repartidor: "M08", zona: "Z1", dia: 3, kilometros: 18,   retraso: 15},
      %{repartidor: "M08", zona: "Z3", dia: 3, kilometros: 20,   retraso: 0},
      %{repartidor: "M09", zona: "Z2", dia: 3, kilometros: 32,   retraso: -3},
      %{repartidor: "M09", zona: "Z4", dia: 3, kilometros: 28,   retraso: 10},
      %{repartidor: "M10", zona: "Z1", dia: 3, kilometros: 15,   retraso: 5},
      %{repartidor: "M10", zona: "Z3", dia: 3, kilometros: 20,   retraso: 25},

      # ----------------------------------------------------------
      # DÍA 4 — 14 servicios válidos
      # M01: 38+44 = 82 km → BONIFICACIÓN
      # M05: 40+42 = 82 km → BONIFICACIÓN
      # ----------------------------------------------------------
      %{repartidor: "M01", zona: "Z1", dia: 4, kilometros: 38,   retraso: -7},
      %{repartidor: "M01", zona: "Z3", dia: 4, kilometros: 44,   retraso: 12},
      %{repartidor: "M02", zona: "Z2", dia: 4, kilometros: 30,   retraso: 0},
      %{repartidor: "M02", zona: "Z4", dia: 4, kilometros: 25,   retraso: -15},
      %{repartidor: "M04", zona: "Z1", dia: 4, kilometros: 20,   retraso: 35},
      %{repartidor: "M04", zona: "Z2", dia: 4, kilometros: 22,   retraso: 5},
      %{repartidor: "M05", zona: "Z2", dia: 4, kilometros: 40,   retraso: -20},
      %{repartidor: "M05", zona: "Z4", dia: 4, kilometros: 42,   retraso: 3},
      %{repartidor: "M06", zona: "Z1", dia: 4, kilometros: 28,   retraso: 18},
      %{repartidor: "M06", zona: "Z3", dia: 4, kilometros: 32,   retraso: 0},
      %{repartidor: "M08", zona: "Z2", dia: 4, kilometros: 15,   retraso: -5},
      %{repartidor: "M08", zona: "Z4", dia: 4, kilometros: 20,   retraso: 8},
      %{repartidor: "M09", zona: "Z1", dia: 4, kilometros: 25,   retraso: 22},
      %{repartidor: "M10", zona: "Z2", dia: 4, kilometros: 18,   retraso: -10},

      # ----------------------------------------------------------
      # DÍA 5 — 14 servicios válidos
      # M03: 45+38 = 83 km → BONIFICACIÓN
      # M07: 40+42 = 82 km → BONIFICACIÓN
      # ----------------------------------------------------------
      %{repartidor: "M03", zona: "Z1", dia: 5, kilometros: 45,   retraso: -15},
      %{repartidor: "M03", zona: "Z3", dia: 5, kilometros: 38,   retraso: 5},
      %{repartidor: "M04", zona: "Z3", dia: 5, kilometros: 30,   retraso: 0},
      %{repartidor: "M04", zona: "Z4", dia: 5, kilometros: 28,   retraso: 20},
      %{repartidor: "M05", zona: "Z1", dia: 5, kilometros: 22,   retraso: 10},
      %{repartidor: "M05", zona: "Z3", dia: 5, kilometros: 18,   retraso: -5},
      %{repartidor: "M06", zona: "Z2", dia: 5, kilometros: 35,   retraso: 40},
      %{repartidor: "M06", zona: "Z4", dia: 5, kilometros: 30,   retraso: 0},
      %{repartidor: "M07", zona: "Z2", dia: 5, kilometros: 40,   retraso: -18},
      %{repartidor: "M07", zona: "Z4", dia: 5, kilometros: 42,   retraso: 2},
      %{repartidor: "M08", zona: "Z3", dia: 5, kilometros: 25,   retraso: 12},
      %{repartidor: "M09", zona: "Z4", dia: 5, kilometros: 20,   retraso: -7},
      %{repartidor: "M10", zona: "Z3", dia: 5, kilometros: 28,   retraso: 3},
      %{repartidor: "M10", zona: "Z4", dia: 5, kilometros: 22,   retraso: 15},

      # ----------------------------------------------------------
      # DÍA 6 — 15 servicios válidos
      # Ningún repartidor supera 80 km en este día
      # ----------------------------------------------------------
      %{repartidor: "M01", zona: "Z2", dia: 6, kilometros: 35,   retraso: 0},
      %{repartidor: "M01", zona: "Z4", dia: 6, kilometros: 38,   retraso: -5},
      %{repartidor: "M02", zona: "Z1", dia: 6, kilometros: 30,   retraso: 25},
      %{repartidor: "M02", zona: "Z3", dia: 6, kilometros: 28,   retraso: -10},
      %{repartidor: "M03", zona: "Z2", dia: 6, kilometros: 22,   retraso: 8},
      %{repartidor: "M03", zona: "Z4", dia: 6, kilometros: 20,   retraso: 3},
      %{repartidor: "M04", zona: "Z1", dia: 6, kilometros: 18,   retraso: -20},
      %{repartidor: "M05", zona: "Z2", dia: 6, kilometros: 32,   retraso: 15},
      %{repartidor: "M05", zona: "Z4", dia: 6, kilometros: 30,   retraso: 0},
      %{repartidor: "M06", zona: "Z1", dia: 6, kilometros: 25,   retraso: 50},
      %{repartidor: "M07", zona: "Z3", dia: 6, kilometros: 28,   retraso: -3},
      %{repartidor: "M08", zona: "Z1", dia: 6, kilometros: 20,   retraso: 5},
      %{repartidor: "M09", zona: "Z2", dia: 6, kilometros: 35,   retraso: 20},
      %{repartidor: "M09", zona: "Z3", dia: 6, kilometros: 30,   retraso: -8},
      %{repartidor: "M10", zona: "Z1", dia: 6, kilometros: 15,   retraso: 10},

      # ==============================================================
      # SERVICIOS INVÁLIDOS — 10 en total (2 por cada motivo)
      # ==============================================================

      # Motivo 1: :repartidor_desconocido
      # El código del repartidor no existe en la lista
      %{repartidor: "M99", zona: "Z1", dia: 1, kilometros: 20,   retraso: 5},
      %{repartidor: "M00", zona: "Z2", dia: 2, kilometros: 15,   retraso: 0},

      # Motivo 2: :zona_desconocida
      # El id de la zona no existe en la lista
      %{repartidor: "M01", zona: "Z5", dia: 1, kilometros: 18,   retraso: 3},
      %{repartidor: "M02", zona: "Z9", dia: 3, kilometros: 25,   retraso: 10},

      # Motivo 3: :dia_invalido
      # El día está fuera del rango 1..6
      %{repartidor: "M03", zona: "Z1", dia: 7, kilometros: 20,   retraso: 5},
      %{repartidor: "M04", zona: "Z2", dia: 0, kilometros: 15,   retraso: 0},

      # Motivo 4: :kilometros_fuera_de_rango
      # Kilómetros <= 0 o > 45
      %{repartidor: "M05", zona: "Z3", dia: 2, kilometros: 50,   retraso: 5},
      %{repartidor: "M06", zona: "Z4", dia: 4, kilometros: 0,    retraso: 0},

      # Motivo 5: :retraso_invalido
      # Retraso fuera del rango -30..180
      %{repartidor: "M07", zona: "Z1", dia: 3, kilometros: 20,   retraso: 185},
      %{repartidor: "M08", zona: "Z2", dia: 5, kilometros: 18,   retraso: -35}
    ]
  end
end
