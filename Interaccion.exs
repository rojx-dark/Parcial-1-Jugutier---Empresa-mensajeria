defmodule Interaccion do
  @moduledoc """
  Módulo que maneja la interacción con el usuario:
    1. Solicitar un servicio adicional antes de los reportes
    2. Mostrar el comprobante de pago de un repartidor al final

  Todas las funciones de este módulo son IMPURAS (leen del teclado
  e imprimen), pero los cálculos los delegan a Validacion y Calculos.
  """

  # --------------------------------------------------
  # PARTE 1: Servicio adicional
  # --------------------------------------------------

  @doc """
  Solicita al usuario un servicio adicional antes de generar los reportes.

  Muestra el mensaje:
    Ingrese un servicio adicional
    (repartidor;zona;dia;kilometros;retraso)
    o Enter para omitir:

  Comportamiento:
    - Si el usuario presiona Enter (cadena vacía): informa que se omitió
      y retorna los servicios sin cambios.
    - Si ingresa algo: lo convierte (formato) y lo valida (reglas).

  Retorna la lista de servicios válidos (con o sin el nuevo servicio).
  """
  def agregar_servicio_adicional(servicios_validos, repartidores, zonas) do
    Util2.mostrar("\nIngrese un servicio adicional", :mensaje)
    Util2.mostrar("(repartidor;zona;dia;kilometros;retraso)", :mensaje)
    Util2.mostrar("o Enter para omitir:", :mensaje)

    # Util2.ingresar/2 ya devuelve el texto sin espacios ni saltos de línea
    entrada = Util2.ingresar("", :texto)

    # Caso 1: entrada vacía - informa y retorna servicios_validos
    # Caso 2: tiene contenido - procesar_entrada/4
    if entrada == "" do
      Util2.mostrar("No se ingresó servicio adicional.", :mensaje)
      servicios_validos
    else
      procesar_entrada(entrada, servicios_validos, repartidores, zonas)
    end
  end

  # Procesa la entrada del usuario: convierte, valida e informa el resultado.
  defp procesar_entrada(entrada, servicios_validos, repartidores, zonas) do
    case parsear_servicio(entrada) do
      {:error, :formato_invalido} ->
        Util2.mostrar(
          "Servicio rechazado por formato: se esperan 5 campos " <>
            "(repartidor;zona;dia;kilometros;retraso) con día entero y valores numéricos.",
          :mensaje
        )

        servicios_validos

      {:ok, servicio} ->
        case Validacion.validar_servicio(servicio, repartidores, zonas) do
          {:ok, servicio_valido} ->
            Util2.mostrar("Servicio agregado correctamente.", :mensaje)
            [servicio_valido | servicios_validos]

          {:error, motivo} ->
            Util2.mostrar("Servicio rechazado por regla de validación: #{motivo}", :mensaje)
            servicios_validos
        end
    end
  end

  # Convierte "repartidor;zona;dia;kilometros;retraso" en un servicio.
  # Solo revisa el formato; las reglas de negocio las valida Validacion.
  defp parsear_servicio(entrada) do
    campos =
      entrada
      |> String.split(";")
      |> Enum.map(&String.trim/1)

    # Debe tener exactamente 5 campos y el día, los km y el retraso deben ser numéricos
    with [repartidor, zona, dia_texto, km_texto, retraso_texto] <- campos,
         {dia, ""} <- Integer.parse(dia_texto),
         {:ok, kilometros} <- parsear_numero(km_texto),
         {:ok, retraso} <- parsear_numero(retraso_texto) do
      {:ok,
       %{
         repartidor: repartidor,
         zona: zona,
         dia: dia,
         kilometros: kilometros,
         retraso: retraso
       }}
    else
      _ -> {:error, :formato_invalido}
    end
  end

  # Convierte un texto en entero o decimal. Rechaza textos con basura
  # al final (por ejemplo "22abc" o "22,5").
  defp parsear_numero(texto) do
    case Integer.parse(texto) do
      {numero, ""} ->
        {:ok, numero}

      _ ->
        case Float.parse(texto) do
          {numero, ""} -> {:ok, numero}
          _ -> :error
        end
    end
  end

  # --------------------------------------------------
  # PARTE 2: Comprobante del repartidor
  # --------------------------------------------------

  @doc """
  Solicita el código de un repartidor y muestra su comprobante de pago.

  Muestra el mensaje:
    Ingrese el código del repartidor para ver su comprobante:

  Comportamiento:
    - Busca el repartidor en la lista.
    - Si no existe: muestra "Repartidor no encontrado." y continúa.
    - Si existe: imprime el comprobante.

  Recibe:
    - servicios_validos: lista de servicios válidos (ya con el adicional
      si se agregó)
    - repartidores: lista de repartidores
  """
  def mostrar_comprobante(servicios_validos, repartidores) do
    Util2.mostrar("\nIngrese el código del repartidor para ver su comprobante:", :mensaje)
    codigo = "" |> Util2.ingresar(:texto) |> String.upcase()

    # Se filtran los repartidores con ese código: lista vacía = no existe
    case Enum.filter(repartidores, fn r -> r.codigo == codigo end) do
      [] ->
        Util2.mostrar("Repartidor no encontrado.", :mensaje)

      [repartidor | _resto] ->
        imprimir_comprobante(repartidor, servicios_validos)
    end
  end

  # Imprime el comprobante de pago de un repartidor.
  defp imprimir_comprobante(repartidor, servicios_validos) do
    # Detalle por día (solo días con servicios válidos) y liquidación total
    detalle = Calculos.calcular_detalle_por_dia(repartidor, servicios_validos)
    liquidacion = Calculos.calcular_liquidacion(repartidor, servicios_validos)

    # Encabezado con nombre y código
    Util2.mostrar("\n=== COMPROBANTE DE PAGO ===", :mensaje)
    Util2.mostrar("Repartidor: #{repartidor.nombre} (#{repartidor.codigo})", :mensaje)
    Util2.mostrar("\nDetalle por día:", :mensaje)

    # Un bloque por cada día trabajado
    Enum.each(detalle, fn d ->
      Util2.mostrar("  Día #{d.dia}:", :mensaje)
      Util2.mostrar("    Kilómetros: #{d.kilometros}", :mensaje)
      Util2.mostrar("    Valor servicios: $#{redondear(d.valor_servicios)}", :mensaje)
      Util2.mostrar("    Bonificación: $#{redondear(d.bonificacion)}", :mensaje)
    end)

    # Totales
    Util2.mostrar("\nTotal valor servicios: $#{redondear(liquidacion.valor_servicios)}", :mensaje)
    Util2.mostrar("Total bonificaciones: $#{redondear(liquidacion.bonificaciones)}", :mensaje)
    Util2.mostrar("Descuento alquiler bicicleta: $#{redondear(liquidacion.alquiler)}", :mensaje)
    Util2.mostrar("NETO A PAGAR: $#{redondear(liquidacion.neto)}", :mensaje)
  end

  # Redondea a 2 decimales. El `* 1.0` evita el error de Float.round con enteros.
  defp redondear(numero), do: Float.round(numero * 1.0, 2)
end
 