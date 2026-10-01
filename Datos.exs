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
end
