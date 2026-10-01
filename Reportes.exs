# Integrantes:
# - Daniela Alvarez Acosta
# - Juan Manuel Rojas
# - Miguel Angel Lopez

defmodule Reportes do
  @moduledoc """
  Módulo que genera los 8 reportes del sistema.
  """

  # --------------------------------------------------
  # R1 — Servicios rechazados
  # --------------------------------------------------

  @doc """
  Muestra los servicios rechazados, el motivo de cada uno
  y la cantidad de rechazos por motivo.

  Recibe:
    - rechazados: lista de motivos (átomos) de los servicios inválidos
      Ejemplo: [:repartidor_desconocido, :dia_invalido, :dia_invalido, ...]

  Debe mostrar:
    - Cada motivo de rechazo
    - Al final: cuántas veces aparece cada motivo
  """
  def r1(rechazados) do
    Util.mostrar_mensaje("\n=== R1: Servicios rechazados ===")
  end

  # --------------------------------------------------
  # R2 — Kilómetros por zona y densidad
  # --------------------------------------------------

  @doc """
  Muestra los kilómetros recorridos en cada zona y la densidad de recorrido
  (km / área), ordenados de mayor a menor densidad.

  Una zona sin servicios válidos aparece con 0 km.

  Recibe:
    - servicios_validos: lista de servicios válidos
    - zonas: lista de todas las zonas

  Fórmula densidad: km_zona / zona.area
  """
  def r2(servicios_validos, zonas) do
    Util.mostrar_mensaje("\n=== R2: Kilómetros por zona y densidad ===")
  end

  # --------------------------------------------------
  # R3 — Kilómetros por día y meta
  # --------------------------------------------------

  @doc """
  Muestra los kilómetros recorridos por TODA la empresa en cada uno de
  los 6 días e indica si se alcanzó la meta de 500 km.

  Al final indica:
    - ¿Se alcanzó la meta TODOS los días?
    - ¿Se alcanzó la meta AL MENOS UN día?

  Recibe:
    - servicios_validos: lista de todos los servicios válidos

  Retorna el mapa de km por día (necesario para la investigación).
    %{1 => 620.5, 2 => 480.0, ...}
  """
  def r3(servicios_validos) do
    Util.mostrar_mensaje("\n=== R3: Kilómetros por día y meta ===")
  end
end
