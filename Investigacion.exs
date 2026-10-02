defmodule Investigacion do
  @moduledoc """
  Parte C del parcial: investigación.

    1. `ranking/2` configurada mediante keyword lists.
    2. Combinación de kilómetros con una empresa aliada usando `Map.merge/3`.
    3. Mediciones de tiempo con `:timer.tc/1`.

  `ranking/2` y `combinar_km_diarios/2` son funciones puras; las demás
  imprimen y por tanto son impuras.
  """

  # --------------------------------------------------
  # 1. ranking/2 con keyword lists
  # --------------------------------------------------

  @doc """
  Ordena una lista de liquidaciones según las opciones recibidas.

  ## Parámetros

  - `liquidaciones`: lista de mapas de liquidación.
  - `opciones`: keyword list con las claves (todas opcionales):
    - `:campo`: campo por el cual ordenar. Por defecto `:neto`.
    - `:orden`: `:asc` o `:desc`. Por defecto `:desc`.
    - `:minimo`: solo se incluyen los que tengan el campo mayor o igual
      a este valor. Por defecto `0`.

  ## Ejemplos

      Investigacion.ranking(liquidaciones)

      Investigacion.ranking(liquidaciones, campo: :kilometros, orden: :asc)

      Investigacion.ranking(liquidaciones, campo: :neto, minimo: 1_000_000)
  """
  def ranking(liquidaciones, opciones \\ []) do
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    minimo = Keyword.get(opciones, :minimo, 0)

    liquidaciones
    |> Enum.filter(fn l -> Map.get(l, campo) >= minimo end)
    |> Util2.ordenar(orden, fn l -> Map.get(l, campo) end)
  end

  @doc """
  Muestra dos ejemplos de ranking con distintas configuraciones.
  """
  def mostrar_ranking(liquidaciones) do
    Util2.mostrar("\n=== Investigación C1: ranking/2 con keyword lists ===", :mensaje)

    Util2.mostrar("\nPor neto, de mayor a menor (solo con neto mayor a 0):", :mensaje)

    liquidaciones
    |> ranking(campo: :neto, orden: :desc, minimo: 1)
    |> Enum.each(fn l -> Util2.mostrar("  #{l.nombre}: $#{redondear(l.neto)}", :mensaje) end)

    Util2.mostrar("\nPor kilómetros, de menor a mayor:", :mensaje)

    liquidaciones
    |> ranking(campo: :kilometros, orden: :asc)
    |> Enum.each(fn l -> Util2.mostrar("  #{l.nombre}: #{l.kilometros} km", :mensaje) end)
  end

  # --------------------------------------------------
  # 2. Map.merge/3 con la empresa aliada
  # --------------------------------------------------

  @doc """
  Combina los kilómetros diarios de la empresa con los de la empresa aliada.

  Cuando un día aparece en ambos mapas, los kilómetros se SUMAN.
  Un día que aparece en un solo mapa se conserva tal cual.

  ## Por qué Map.merge/3 y no Map.merge/2

  `Map.merge/2` ante una clave repetida se queda con el valor del segundo
  mapa (lo sobrescribe), así que los kilómetros de la empresa en los días
  1, 2, 3 y 5 se perderían en lugar de sumarse. `Map.merge/3` recibe una
  función que decide qué hacer en cada conflicto.

  El día 7 solo existe en el mapa de la aliada: como no hay conflicto, la
  función de combinación no se llama y el día se agrega sin cambios.

  ## Ejemplo

      Investigacion.combinar_km_diarios(%{1 => 100, 2 => 50}, %{2 => 30, 7 => 20})
      # => %{1 => 100, 2 => 80, 7 => 20}
  """
  def combinar_km_diarios(km_por_dia, empresa_aliada) do
    Map.merge(km_por_dia, empresa_aliada, fn _dia, km_propios, km_aliada ->
      km_propios + km_aliada
    end)
  end

  # --------------------------------------------------
  # 3. Mediciones con :timer.tc/1
  # --------------------------------------------------

  @doc """
  Mide cuánto tarda en calcularse la liquidación de todos los repartidores
  con 1, 10 y 100 veces la cantidad de servicios.

  `:timer.tc/1` recibe una función sin argumentos y retorna una tupla
  `{microsegundos, resultado}`. Los tiempos cambian en cada ejecución.
  """
  def medir_tiempos(servicios_validos, repartidores, _zonas) do
    Util2.mostrar("\n=== Investigación C3: mediciones con :timer.tc/1 ===", :mensaje)

    Enum.each([1, 10, 100], fn veces ->
      # Repite la lista de servicios `veces` veces para aumentar el tamaño
      servicios = for _copia <- 1..veces, servicio <- servicios_validos, do: servicio

      {microsegundos, _resultado} =
        :timer.tc(fn -> Calculos.calcular_liquidacion_todos(repartidores, servicios) end)

      Util2.mostrar(
        "#{length(servicios)} servicios: #{microsegundos} microsegundos",
        :mensaje
      )
    end)
  end

  # Redondea a 2 decimales. El `* 1.0` evita el error de Float.round con enteros.
  defp redondear(numero), do: Float.round(numero * 1.0, 2)
end
 