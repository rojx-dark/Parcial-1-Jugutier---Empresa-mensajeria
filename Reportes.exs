# Integrantes: ______

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
    - rechazados: lista de tuplas {servicio, motivo}, como la que
      devuelve Validacion.separar_servicios/3
      Ejemplo: [{%{repartidor: "M99", ...}, :repartidor_desconocido}, ...]

  Debe mostrar:
    - Cada servicio rechazado con su motivo
    - Al final: cuántas veces aparece cada motivo
  """
  def r1(rechazados) do
    mostrar("\n=== R1: Servicios rechazados ===")

    # Paso 1: muestra cada servicio con su motivo (Enum.each)
    Enum.each(rechazados, fn {servicio, motivo} ->
      mostrar(
        "Repartidor: #{servicio.repartidor} | Zona: #{servicio.zona} | " <>
          "Día: #{servicio.dia} | Km: #{servicio.kilometros} | " <>
          "Retraso: #{servicio.retraso} -> #{motivo}"
      )
    end)

    # Paso 2: cuenta por motivo con Enum.frequencies
    conteo =
      rechazados
      |> Enum.map(fn {_servicio, motivo} -> motivo end)
      |> Enum.frequencies()

    # Paso 3: muestra el conteo
    mostrar("\nRechazos por motivo:")

    Enum.each(conteo, fn {motivo, cantidad} ->
      mostrar("  #{motivo}: #{cantidad}")
    end)
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
    mostrar("\n=== R2: Kilómetros por zona y densidad ===")

    # Paso 1: agrupa servicios por zona
    por_zona = Enum.group_by(servicios_validos, & &1.zona)

    # Paso 2: para cada zona calcula km totales y densidad
    zonas
    |> Enum.map(fn zona ->
      km =
        por_zona
        |> Map.get(zona.id, [])
        |> Enum.map(& &1.kilometros)
        |> Enum.sum()

      %{zona: zona, kilometros: km, densidad: km / zona.area}
    end)
    # Paso 3: ordena de mayor a menor densidad
    |> Util2.ordenar(:desc, & &1.densidad)
    # Paso 4: imprime cada zona con sus datos
    |> Enum.each(fn fila ->
      mostrar(
        "#{fila.zona.id} #{String.pad_trailing(fila.zona.nombre, 8)} | " <>
          "Km: #{fila.kilometros} | Área: #{fila.zona.area} km² | " <>
          "Densidad: #{Float.round(fila.densidad, 2)} km/km²"
      )
    end)
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
    mostrar("\n=== R3: Kilómetros por día y meta ===")

    meta = Validacion.meta_diaria_km()

    # Paso 1: agrupa servicios por día
    por_dia = Enum.group_by(servicios_validos, & &1.dia)

    # Paso 2: para los 6 días (1..6) calcula km totales (0 si no hay servicios)
    km_por_dia =
      for dia <- 1..6, into: %{} do
        km =
          por_dia
          |> Map.get(dia, [])
          |> Enum.map(& &1.kilometros)
          |> Enum.sum()

        {dia, km}
      end

    # Paso 3: imprime cada día con sus km y si alcanzó la meta
    Enum.each(1..6, fn dia ->
      km = Map.get(km_por_dia, dia)
      estado = if km >= meta, do: "meta alcanzada", else: "meta NO alcanzada"
      mostrar("Día #{dia}: #{km} km -> #{estado}")
    end)

    # Paso 4: ¿todos los días cumplen la meta?
    todos = Enum.all?(km_por_dia, fn {_dia, km} -> km >= meta end)
    # Paso 5: ¿al menos un día cumple la meta?
    alguno = Enum.any?(km_por_dia, fn {_dia, km} -> km >= meta end)

    mostrar("¿Meta alcanzada todos los días? #{if todos, do: "Sí", else: "No"}")
    mostrar("¿Meta alcanzada al menos un día? #{if alguno, do: "Sí", else: "No"}")

    # Paso 6: retorna el mapa %{dia => km_totales}
    km_por_dia
  end

  # --------------------------------------------------
  # R4 — Liquidación de todos los repartidores
  # --------------------------------------------------

  @doc """
  Muestra la liquidación de todos los repartidores, numerada y ordenada
  de mayor a menor por neto.

  Incluye por repartidor:
    - Número de posición
    - Nombre y código
    - Kilómetros totales
    - Valor de servicios
    - Bonificaciones
    - Alquiler
    - Neto

  Recibe:
    - liquidaciones: lista de mapas retornada por Calculos.calcular_liquidacion_todos/2
  """
  def r4(liquidaciones) do
    mostrar("\n=== R4: Liquidación de repartidores ===")

    # Paso 1: ordena liquidaciones por neto desc
    liquidaciones
    |> Util2.ordenar(:desc, & &1.neto)
    # Paso 2: usa Enum.with_index(1) para numerar
    |> Enum.with_index(1)
    # Paso 3: imprime cada repartidor con todos sus datos
    |> Enum.each(fn {l, posicion} ->
      mostrar(
        "#{posicion}. #{l.nombre} (#{l.codigo}) | Km: #{l.kilometros} | " <>
          "Servicios: $#{redondear(l.valor_servicios)} | " <>
          "Bonificaciones: $#{redondear(l.bonificaciones)} | " <>
          "Alquiler: $#{redondear(l.alquiler)} | " <>
          "Neto: $#{redondear(l.neto)}"
      )
    end)
  end

  # --------------------------------------------------
  # R5 — Repartidor con más km cada día
  # --------------------------------------------------

  @doc """
  Muestra el repartidor que recorrió más kilómetros cada día.
  En caso de empate, muestra todos los empatados.
  Al final muestra quién ocupó el primer lugar en más días.

  Recibe:
    - servicios_validos: lista de servicios válidos
    - repartidores: lista de repartidores
  """
  def r5(servicios_validos, repartidores) do
    mostrar("\n=== R5: Repartidor con más km por día ===")

    # Paso 1: agrupa servicios por día
    por_dia = Enum.group_by(servicios_validos, & &1.dia)

    # Paso 2 y 3: para cada día con servicios, suma km por repartidor
    # y encuentra el máximo y los empatados
    ganadores_por_dia =
      for dia <- 1..6, Map.has_key?(por_dia, dia) do
        km_por_repartidor =
          por_dia
          |> Map.get(dia)
          |> Enum.group_by(& &1.repartidor)
          |> Enum.map(fn {codigo, servicios} ->
            {codigo, servicios |> Enum.map(& &1.kilometros) |> Enum.sum()}
          end)

        {_codigo, maximo} = Enum.max_by(km_por_repartidor, fn {_c, km} -> km end)
        ganadores = for {codigo, km} <- km_por_repartidor, km == maximo, do: codigo

        {dia, maximo, ganadores}
      end

    # Paso 4: imprime ganadores de cada día
    Enum.each(ganadores_por_dia, fn {dia, maximo, ganadores} ->
      nombres = Enum.map(ganadores, fn codigo -> nombre_de(codigo, repartidores) end)
      mostrar("Día #{dia}: #{Enum.join(nombres, ", ")} con #{maximo} km")
    end)

    # Paso 5: cuenta quién ganó más días y muéstralo
    victorias =
      ganadores_por_dia
      |> Enum.flat_map(fn {_dia, _maximo, ganadores} -> ganadores end)
      |> Enum.frequencies()

    if victorias == %{} do
      mostrar("No hubo servicios válidos.")
    else
      {_codigo, mas_dias} = Enum.max_by(victorias, fn {_c, dias} -> dias end)
      primeros = for {codigo, dias} <- victorias, dias == mas_dias, do: codigo
      nombres = Enum.map(primeros, fn codigo -> nombre_de(codigo, repartidores) end)

      mostrar("Primer lugar en más días: #{Enum.join(nombres, ", ")} (#{mas_dias} días)")
    end
  end

  # --------------------------------------------------
  # R6 — Mejor puntualidad ponderada
  # --------------------------------------------------

  @doc """
  Muestra el repartidor con mejor puntualidad entre quienes tengan
  al menos 3 servicios válidos.

  La puntualidad se mide con el retraso promedio PONDERADO por kilómetros:
    suma(retraso * km) / suma(km)

  El MENOR valor ponderado es el mejor (puede ser negativo = entrega anticipada).

  Recibe:
    - servicios_validos: lista de servicios válidos
    - repartidores: lista de repartidores
  """
  def r6(servicios_validos, repartidores) do
    mostrar("\n=== R6: Mejor puntualidad ponderada ===")

    # Paso 1: agrupa servicios por código de repartidor
    # Paso 2: filtra grupos con length >= 3
    # Paso 3: calcula retraso ponderado para cada grupo
    candidatos =
      servicios_validos
      |> Enum.group_by(& &1.repartidor)
      |> Enum.filter(fn {_codigo, servicios} -> length(servicios) >= 3 end)
      |> Enum.map(fn {codigo, servicios} ->
        suma_ponderada = servicios |> Enum.map(fn s -> s.retraso * s.kilometros end) |> Enum.sum()
        suma_km = servicios |> Enum.map(& &1.kilometros) |> Enum.sum()
        {codigo, suma_ponderada / suma_km, length(servicios)}
      end)

    # Paso 4: encuentra el mínimo con Enum.min_by
    # Paso 5: busca el nombre del repartidor ganador e imprímelo
    if candidatos == [] do
      mostrar("Ningún repartidor tiene al menos 3 servicios válidos.")
    else
      {codigo, ponderado, cantidad} = Enum.min_by(candidatos, fn {_c, p, _n} -> p end)

      mostrar(
        "Mejor puntualidad: #{nombre_de(codigo, repartidores)} (#{codigo}) | " <>
          "Retraso ponderado: #{Float.round(ponderado, 2)} min | " <>
          "Servicios: #{cantidad}"
      )
    end
  end

  # --------------------------------------------------
  # R7 — Total pagado y costo por km
  # --------------------------------------------------

  @doc """
  Muestra el total pagado a todos los repartidores durante la semana
  y el costo promedio por kilómetro.

  Fórmula:
    total_pagado   = suma de todos los netos de la liquidación
    km_totales     = suma de todos los kilómetros de la liquidación
    costo_por_km   = total_pagado / km_totales

  Recibe:
    - liquidaciones: lista de mapas de liquidación
  """
  def r7(liquidaciones) do
    mostrar("\n=== R7: Total pagado y costo por km ===")

    # Paso 1: suma todos los netos
    total_pagado = Enum.sum(Enum.map(liquidaciones, & &1.neto))
    # Paso 2: suma todos los kilómetros
    km_totales = Enum.sum(Enum.map(liquidaciones, & &1.kilometros))

    mostrar("Total pagado: $#{redondear(total_pagado)}")
    mostrar("Kilómetros totales: #{km_totales}")

    # Paso 3: calcula y muestra el costo por km (evita dividir entre cero)
    if km_totales > 0 do
      mostrar("Costo promedio por km: $#{redondear(total_pagado / km_totales)}")
    else
      mostrar("Costo promedio por km: no se puede calcular (0 km)")
    end
  end

  # --------------------------------------------------
  # R8 — Repartidores en todas las zonas
  # --------------------------------------------------

  @doc """
  Muestra los repartidores que realizaron al menos un servicio válido
  en TODAS las zonas.

  Recibe:
    - servicios_validos: lista de servicios válidos
    - repartidores: lista de repartidores
    - zonas: lista de zonas
  """
  def r8(servicios_validos, repartidores, zonas) do
    mostrar("\n=== R8: Repartidores en todas las zonas ===")

    # Paso 1: crea el MapSet de ids de zonas requeridas
    requeridas = MapSet.new(Enum.map(zonas, & &1.id))

    # Paso 2: agrupa servicios por repartidor
    por_repartidor = Enum.group_by(servicios_validos, & &1.repartidor)

    # Paso 3: para cada repartidor verifica si cubrió todas las zonas
    cumplen =
      Enum.filter(repartidores, fn repartidor ->
        trabajadas =
          por_repartidor
          |> Map.get(repartidor.codigo, [])
          |> Enum.map(& &1.zona)
          |> MapSet.new()

        MapSet.subset?(requeridas, trabajadas)
      end)

    # Paso 4: filtra y muestra los que cumplen
    if cumplen == [] do
      mostrar("Ningún repartidor trabajó en todas las zonas.")
    else
      Enum.each(cumplen, fn r -> mostrar("#{r.nombre} (#{r.codigo})") end)
    end
  end

  # --------------------------------------------------
  # Funciones auxiliares privadas
  # --------------------------------------------------

  # Imprime un mensaje usando el módulo de utilidades del curso.
  defp mostrar(mensaje), do: Util2.mostrar(mensaje, :mensaje)

  # Redondea a 2 decimales. El `* 1.0` evita el error de Float.round con enteros
  # (por ejemplo, el neto de un repartidor sin servicios es el entero 0).
  defp redondear(numero), do: Float.round(numero * 1.0, 2)

  # Busca el nombre de un repartidor por su código.
  defp nombre_de(codigo, repartidores) do
    case Enum.find(repartidores, fn r -> r.codigo == codigo end) do
      nil -> codigo
      repartidor -> repartidor.nombre
    end
  end
end
