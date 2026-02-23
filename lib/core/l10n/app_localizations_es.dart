// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SimpleLog';

  @override
  String get homeTitle => 'SimpleLog';

  @override
  String get addAction => 'Agregar';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get languageSystem => 'Sistema';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageSpanish => 'Español';

  @override
  String get screenMenu => 'Pantallas';

  @override
  String get screenLogbook => 'Libro de vuelo';

  @override
  String get logbookFilterAction => 'Filtros';

  @override
  String get logbookFilterTitle => 'Filtros';

  @override
  String get logbookFilterFromDate => 'Desde';

  @override
  String get logbookFilterToDate => 'Hasta';

  @override
  String get logbookFilterRange => 'Rango de fechas';

  @override
  String get logbookFilterApply => 'Aplicar filtros';

  @override
  String get logbookFilterPresetCustom => 'Personalizado';

  @override
  String get logbookFilterPresetSinceFirstFlight => 'Desde el primer vuelo';

  @override
  String get logbookFilterPresetLast7Days => 'Últimos 7 días';

  @override
  String get logbookFilterPresetLast14Days => 'Últimos 14 días';

  @override
  String get logbookFilterPresetLast21Days => 'Últimos 21 días';

  @override
  String get logbookFilterPresetLast28Days => 'Últimos 28 días';

  @override
  String get logbookFilterPresetLast365Days => 'Últimos 365 días';

  @override
  String get logbookFilterPresetLastMonth => 'Mes pasado';

  @override
  String get logbookFilterPresetLastYear => 'Año pasado';

  @override
  String get logbookFilterPresetCurrentMonth => 'Mes actual';

  @override
  String get logbookFilterPresetCurrentYear => 'Año actual';

  @override
  String get logbookFilterEventTypes => 'Tipos de evento';

  @override
  String get logbookFilterAdvanced => 'Filtros avanzados (próximamente)';

  @override
  String get logbookEventFlight => 'Vuelo';

  @override
  String get logbookEventSimulator => 'Entrenamiento en simulador';

  @override
  String get logbookEventDuty => 'Período de servicio';

  @override
  String get logbookEventDutyStart => 'Inicio de servicio';

  @override
  String get logbookEventDutyEnd => 'Fin de servicio';

  @override
  String get logbookEventPositioning => 'Posicionamiento';

  @override
  String get logbookEventUnknown => 'Evento';

  @override
  String get screenAircraft => 'Aeronaves';

  @override
  String get screenAircraftTypes => 'Tipos de aeronaves';

  @override
  String get screenAirports => 'Aeropuertos';

  @override
  String get screenCrew => 'Tripulación';

  @override
  String get screenReports => 'Informes';

  @override
  String get screenDatabase => 'Base de datos';

  @override
  String get screenSettings => 'Ajustes';

  @override
  String get searchAircraft => 'Buscar aeronaves';

  @override
  String get searchCrew => 'Buscar tripulacion';

  @override
  String get searchAirports => 'Buscar aeropuertos';

  @override
  String get searchAircraftTypes => 'Buscar tipos de aeronaves';

  @override
  String get emptyResults => 'No se encontraron resultados';

  @override
  String get lockAction => 'Bloquear';

  @override
  String get editAction => 'Editar';

  @override
  String get deleteAction => 'Eliminar';

  @override
  String get cancelAction => 'Cancelar';

  @override
  String get confirmDeleteTitle => 'Confirmar eliminacion';

  @override
  String confirmDeleteAircraftType(String code) {
    return 'Eliminar tipo de aeronave $code?';
  }

  @override
  String confirmDeleteAircraft(String registration) {
    return 'Eliminar aeronave $registration?';
  }

  @override
  String confirmDeleteCrew(String name) {
    return 'Eliminar tripulante $name?';
  }

  @override
  String confirmDeleteAirport(String icao) {
    return 'Eliminar aeropuerto $icao?';
  }

  @override
  String get settingsAppearance => 'Apariencia';

  @override
  String get settingsDeveloper => 'Desarrollo';

  @override
  String get themeSystem => 'Seguir el sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get editAircraftTypeTitle => 'Editar tipo de aeronave';

  @override
  String get createAircraftTypeTitle => 'Agregar tipo de aeronave';

  @override
  String get editAircraftTitle => 'Editar aeronave';

  @override
  String get createAircraftTitle => 'Agregar aeronave';

  @override
  String get editCrewTitle => 'Editar tripulacion';

  @override
  String get createCrewTitle => 'Agregar tripulacion';

  @override
  String get editAirportTitle => 'Editar aeropuerto';

  @override
  String get createAirportTitle => 'Agregar aeropuerto';

  @override
  String get saveAction => 'Guardar';

  @override
  String get okAction => 'Aceptar';

  @override
  String get validationErrorTitle => 'Error de validacion';

  @override
  String get validationErrorGeneric =>
      'Revise el formulario y vuelva a intentar.';

  @override
  String get codeRequired => 'El codigo es obligatorio';

  @override
  String get nameRequired => 'El nombre es obligatorio';

  @override
  String get codeDuplicateTitle => 'Codigo duplicado';

  @override
  String codeDuplicateMessage(String code) {
    return 'El codigo $code ya existe.';
  }

  @override
  String get deleteBlockedTitle => 'Eliminacion bloqueada';

  @override
  String deleteBlockedAircraftType(int count) {
    return 'Este tipo de aeronave se usa en $count aeronaves y no se puede eliminar.';
  }

  @override
  String get fieldCode => 'Codigo';

  @override
  String get fieldRegistration => 'Matricula';

  @override
  String get fieldAircraftType => 'Tipo de aeronave';

  @override
  String get fieldFamily => 'Familia';

  @override
  String get fieldLongName => 'Nombre del tipo';

  @override
  String get fieldManufacturer => 'Fabricante';

  @override
  String get fieldCategory => 'Categoria';

  @override
  String get fieldEngineType => 'Tipo de motor';

  @override
  String get fieldMtow => 'MTOW';

  @override
  String get fieldEngineCount => 'Numero de motores';

  @override
  String get fieldMultiPilot => 'Multipiloto';

  @override
  String get fieldComplex => 'Complejo';

  @override
  String get fieldEfis => 'EFIS';

  @override
  String get fieldHighPerformance => 'Alto rendimiento';

  @override
  String get fieldName => 'Nombre';

  @override
  String get fieldEmail => 'Correo';

  @override
  String get fieldPhone => 'Telefono';

  @override
  String get fieldNotes => 'Notas';

  @override
  String get fieldPicture => 'Foto';

  @override
  String get pictureHint => 'Toque para agregar/editar foto';

  @override
  String get photoCamera => 'Camara';

  @override
  String get photoLibrary => 'Galeria';

  @override
  String get removePicture => 'Eliminar foto';

  @override
  String get cropPhotoTitle => 'Editar foto';

  @override
  String get fieldIsSelf => 'Propio';

  @override
  String get fieldIsFavorite => 'Favorito';

  @override
  String get fieldIsSimulator => 'Simulador';

  @override
  String get fieldIcao => 'ICAO';

  @override
  String get fieldIata => 'IATA';

  @override
  String get fieldCity => 'Ciudad';

  @override
  String get fieldCountry => 'Pais';

  @override
  String get fieldLatitude => 'Latitud';

  @override
  String get fieldLongitude => 'Longitud';

  @override
  String get aircraftTypeRequired => 'Seleccione un tipo de aeronave';

  @override
  String get registrationDuplicateTitle => 'Matricula duplicada';

  @override
  String registrationDuplicateMessage(String registration) {
    return 'La matricula $registration ya existe.';
  }

  @override
  String get nameDuplicateTitle => 'Nombre duplicado';

  @override
  String nameDuplicateMessage(String name) {
    return 'El nombre $name ya existe.';
  }

  @override
  String get icaoLengthError => 'El ICAO debe tener 4 caracteres';

  @override
  String get icaoDuplicateTitle => 'ICAO duplicado';

  @override
  String icaoDuplicateMessage(String icao) {
    return 'El ICAO $icao ya existe.';
  }

  @override
  String get callNumber => 'Llamar';

  @override
  String get textNumber => 'Enviar mensaje';

  @override
  String get copyNumber => 'Copiar numero';

  @override
  String get sendEmail => 'Enviar correo';

  @override
  String get copyEmail => 'Copiar correo';

  @override
  String get seedTestData => 'Insertar datos de prueba';

  @override
  String get seedDataDone => 'Datos de prueba insertados';

  @override
  String get databaseSyncTitle => 'Sincronizacion local';

  @override
  String get databaseSyncStartLocal => 'Iniciar sincronizacion local';

  @override
  String get databaseSyncFoundTitle => 'Dispositivos disponibles';

  @override
  String get databaseSyncSearching => 'Buscando dispositivos en Wi‑Fi...';

  @override
  String get databaseSyncSendAction => 'Enviar al dispositivo';

  @override
  String get databaseSyncPullAction => 'Traer del dispositivo';

  @override
  String get databaseSyncConfirmTitle => 'Confirmar reemplazo';

  @override
  String databaseSyncConfirmMessage(String device) {
    return '⚠️ Esto reemplazara todos los datos en $device.';
  }

  @override
  String get databaseSyncConfirmAction => 'Confirmar';

  @override
  String databaseSyncConnected(String device) {
    return 'Conectado: $device';
  }

  @override
  String get databaseSyncWaiting => 'Esperando transferencia...';

  @override
  String get databaseSyncSchemaMismatchTitle =>
      'Version de base de datos distinta';

  @override
  String databaseSyncSchemaMismatchMessage(Object local, Object remote) {
    return 'No se puede sincronizar porque las versiones son distintas. Este dispositivo usa v$local y el otro usa v$remote. Actualice ambas apps y vuelva a intentar.';
  }

  @override
  String get databaseSyncCopyDebug => 'Copiar depuracion';

  @override
  String get databaseSyncCopied => 'Depuracion copiada';

  @override
  String get databaseSyncLocalServer => 'Servidor local';

  @override
  String get databaseSyncTestServer => 'Probar servidor local';

  @override
  String get databaseSyncSessionInfo =>
      'Inicie una sesion en un dispositivo y unase desde otro.';

  @override
  String get databaseSyncStartSession => 'Iniciar sesion';

  @override
  String get databaseSyncStopSession => 'Detener sesion';

  @override
  String get databaseSyncJoinSession => 'Conectar dispositivo';

  @override
  String get databaseSyncHosting => 'Sesion en curso';

  @override
  String get databaseSyncEnterAddress => 'Ingresar direccion';

  @override
  String get databaseSyncAddressHint =>
      'simplelog://sync?host=192.168.1.10&port=49200';

  @override
  String get databaseSyncConnectedLabel => 'Conectado a';

  @override
  String get databaseSyncNotConnected => 'Sin conexion';

  @override
  String get databaseSyncConnectHint =>
      'Para enviar desde este dispositivo, conecte primero al otro dispositivo.';

  @override
  String get databaseSyncSend => 'Enviar base de datos';

  @override
  String get databaseSyncEnterLastTwo => 'Ingrese los ultimos dos grupos de IP';

  @override
  String get databaseSyncOctet3 => 'Tercer grupo';

  @override
  String get databaseSyncOctet4 => 'Cuarto grupo';

  @override
  String databaseSyncInstruction(String prefix, String octet3, String octet4) {
    return 'En el otro dispositivo, ingrese solo los ultimos dos numeros: $octet3.$octet4 (prefijo $prefix, puerto 54742).';
  }

  @override
  String get databaseSyncSuccess => 'Sincronizacion completa';

  @override
  String get databaseSyncInvalidSession => 'No se pudo conectar a esa sesion.';

  @override
  String get databaseSyncNoNetwork => 'No se encontro una red local.';

  @override
  String get databaseSyncScanQr => 'Escanear codigo QR';

  @override
  String get databaseSyncDisconnected => 'Se desconecto del otro dispositivo.';

  @override
  String get databaseSyncStopWarning =>
      'Detener la sesion desconectara a otros dispositivos. Continuar?';

  @override
  String get reportsTabOverview => 'Resumen';

  @override
  String get reportsTabFlights => 'Vuelos';

  @override
  String get reportsTabTotals => 'Totales';

  @override
  String get reportsTabAnalyses => 'Analisis';

  @override
  String get reportsTabReports => 'Informes';

  @override
  String get reportsTabFilters => 'Filtros';

  @override
  String get reportsEntryGeneric => 'Entrada';

  @override
  String reportsDeleteEntryConfirm(String label) {
    return 'Eliminar $label?';
  }

  @override
  String get reportsDeleteDutyConfirm => 'Eliminar esta entrada de servicio?';

  @override
  String get reportsNoPreviousFlightFound => 'No se encontro vuelo anterior.';

  @override
  String get logbookFabReturnFlight => 'Vuelo de regreso';

  @override
  String get logbookFabNextFlight => 'Siguiente vuelo';

  @override
  String get reportsStartBeforeEndError =>
      'La fecha inicial debe ser anterior a la final.';

  @override
  String reportsSavedQuery(String name) {
    return 'Consulta guardada \"$name\".';
  }

  @override
  String get reportsPdfPreparing => 'Preparando PDF...';

  @override
  String get reportsPdfGenerating => 'Generando PDF...';

  @override
  String get reportsPdfSaving => 'Guardando PDF...';

  @override
  String get reportsPdfDone => 'Listo.';

  @override
  String reportsPdfExported(String path) {
    return 'PDF exportado en: $path';
  }

  @override
  String reportsPdfFailed(String error) {
    return 'Error al generar PDF: $error';
  }

  @override
  String get reportsNoTemplateAvailable => 'No hay plantilla disponible.';

  @override
  String get reportsSavePdfDialogTitle => 'Guardar PDF';

  @override
  String get reportsChooseExportFolderTitle => 'Elegir carpeta de exportacion';

  @override
  String get reportsCancelled => 'Cancelado';

  @override
  String get reportsAnalyzeByLabel => 'Analizar por';

  @override
  String get reportsOrderByLabel => 'Ordenar por';

  @override
  String get reportsAnalyzeByAircraft => 'Por aeronave';

  @override
  String get reportsAnalyzeByType => 'Por tipo';

  @override
  String get reportsAnalyzeByFamily => 'Por familia';

  @override
  String get reportsAnalyzeByYear => 'Por ano';

  @override
  String get reportsAnalyzeByMonth => 'Por mes';

  @override
  String get reportsOrderByGreater => 'Mayor';

  @override
  String get reportsOrderByNatural => 'Natural';

  @override
  String get reportsShowMap => 'Mostrar mapa';

  @override
  String get reportsShowPath => 'Mostrar ruta';

  @override
  String get reportsIncludeHoursBefore => 'Incluir horas anteriores';

  @override
  String get reportsPageSizeLabel => 'Tamano de pagina';

  @override
  String get reportsXmlTemplateLabel => 'Plantilla XML';

  @override
  String get reportsGeneratingShort => 'Generando...';

  @override
  String get reportsGeneratePdf => 'Generar PDF';

  @override
  String get reportsDatePresetLastMonthRolling => 'Ultimo mes (movil)';

  @override
  String get reportsUnknown => 'Desconocido';

  @override
  String get reportsUnknownType => 'Tipo desconocido';

  @override
  String get reportsUnknownFamily => 'Familia desconocida';

  @override
  String reportsFiltersSummary(int count, String from, String to) {
    return '$count filtros • $from UTC - $to UTC';
  }

  @override
  String get reportsEventSimShort => 'Sim';

  @override
  String get reportsPreviousExperienceLabel => 'Experiencia previa';

  @override
  String get reportsInclude => 'Incluir';

  @override
  String get reportsExclude => 'Excluir';

  @override
  String get reportsMatchModeLabel => 'Modo de coincidencia';

  @override
  String get reportsMatchAll => 'Todos';

  @override
  String get reportsMatchAny => 'Cualquiera';

  @override
  String get reportsAddFilter => 'Agregar filtro';

  @override
  String reportsFilterChipLabel(String field, String operator, String value) {
    return '$field · $operator · $value';
  }

  @override
  String get reportsSavedQueriesLabel => 'Consultas guardadas';

  @override
  String get reportsSaveQuery => 'Guardar consulta';

  @override
  String reportsDeleteSavedQuery(String name) {
    return 'Eliminar: $name';
  }

  @override
  String get reportsDeleteSavedLabel => 'Eliminar guardada';

  @override
  String get reportsMetricIfrApproaches => 'Aproximaciones IFR';

  @override
  String get reportsMetricTakeoffDay => 'Despegues dia';

  @override
  String get reportsMetricTakeoffNight => 'Despegues noche';

  @override
  String get reportsMetricLandingDay => 'Aterrizajes dia';

  @override
  String get reportsMetricLandingNight => 'Aterrizajes noche';

  @override
  String get reportsMetricTotalBlock => 'Total block';

  @override
  String get reportsMetricPic => 'PIC';

  @override
  String get reportsMetricPicus => 'PICUS';

  @override
  String get reportsMetricSic => 'SIC';

  @override
  String get reportsMetricDual => 'Dual';

  @override
  String get reportsMetricInstructor => 'Instructor';

  @override
  String get reportsMetricNight => 'Noche';

  @override
  String get reportsMetricIfr => 'IFR';

  @override
  String get reportsMetricInstrument => 'Instrumental';

  @override
  String get reportsMetricCrossCountry => 'Travesia';

  @override
  String get reportsMetricSimulator => 'Simulador';

  @override
  String get reportsMetricDuty => 'Servicio';

  @override
  String get reportsMetricDistanceNm => 'Distancia NM';

  @override
  String reportsFlightCount(String count) {
    return 'Cantidad de vuelos: $count';
  }

  @override
  String get reportsNoDataForQuery =>
      'No hay datos para la consulta seleccionada.';

  @override
  String get reportsMetricLandings => 'Aterrizajes';

  @override
  String reportsFirstFlightAt(String date) {
    return 'Primer vuelo $date UTC';
  }

  @override
  String reportsLastFlightAt(String date) {
    return 'Ultimo vuelo $date UTC';
  }

  @override
  String get reportsFieldNameLabel => 'Nombre del campo';

  @override
  String get reportsConditionLabel => 'Condicion';

  @override
  String get reportsValueLabel => 'Valor';

  @override
  String get reportsFlightsAndSimulatorTitle => 'Vuelos y simulador';

  @override
  String reportsEntriesCount(int count) {
    return '$count entradas';
  }

  @override
  String get reportsNoFlightsInPeriod =>
      'No hay vuelos/sim en el periodo seleccionado.';

  @override
  String get reportsFlightMapTitle => 'Mapa de vuelos';

  @override
  String get reportsHideLines => 'Ocultar lineas';

  @override
  String get reportsShowLines => 'Mostrar lineas';

  @override
  String get reportsDone => 'Listo';

  @override
  String get reportsNoCoordinatesAvailable => 'No hay coordenadas disponibles.';

  @override
  String reportsAirportsCount(int count) {
    return 'Aeropuertos: $count';
  }

  @override
  String get reportsFilterFieldDepartureIcao => 'Salida ICAO';

  @override
  String get reportsFilterFieldDepartureIata => 'Salida IATA';

  @override
  String get reportsFilterFieldDepartureName => 'Nombre salida';

  @override
  String get reportsFilterFieldDepartureCity => 'Ciudad salida';

  @override
  String get reportsFilterFieldDepartureCountry => 'Pais salida';

  @override
  String get reportsFilterFieldArrivalIcao => 'Llegada ICAO';

  @override
  String get reportsFilterFieldArrivalIata => 'Llegada IATA';

  @override
  String get reportsFilterFieldArrivalName => 'Nombre llegada';

  @override
  String get reportsFilterFieldArrivalCity => 'Ciudad llegada';

  @override
  String get reportsFilterFieldArrivalCountry => 'Pais llegada';

  @override
  String get reportsFilterFieldAircraftRegistration => 'Matricula aeronave';

  @override
  String get reportsFilterFieldAircraftTypeCode => 'Codigo tipo aeronave';

  @override
  String get reportsFilterFieldAircraftTypeFamily => 'Familia tipo aeronave';

  @override
  String get reportsFilterFieldAircraftTypeName => 'Nombre tipo aeronave';

  @override
  String get reportsFilterFieldPilotName => 'Nombre piloto';

  @override
  String get reportsFilterFieldPilotOnBoard => 'Piloto a bordo';

  @override
  String get reportsFilterFieldPilotPic => 'Piloto PIC';

  @override
  String get reportsFilterFieldPilotSic => 'Piloto SIC';

  @override
  String get reportsFilterFieldPilotTrainee => 'Piloto en entrenamiento';

  @override
  String get reportsFilterFieldApproachType => 'Tipo de aproximacion';

  @override
  String get reportsFilterFieldRemarks => 'Observaciones';

  @override
  String get reportsFilterFieldNotes => 'Notas';

  @override
  String get reportsFilterFieldBlockTime => 'Tiempo block';

  @override
  String get reportsFilterFieldFlightTime => 'Tiempo de vuelo';

  @override
  String get reportsFilterFieldTotalTime => 'Tiempo total';

  @override
  String get reportsFilterFieldNightTime => 'Tiempo nocturno';

  @override
  String get reportsFilterFieldIfrTime => 'Tiempo IFR';

  @override
  String get reportsFilterFieldInstrumentTime => 'Tiempo instrumental';

  @override
  String get reportsFilterFieldSimInstrumentTime =>
      'Tiempo instrumental simulado';

  @override
  String get reportsFilterFieldPicTime => 'Tiempo PIC';

  @override
  String get reportsFilterFieldPicusTime => 'Tiempo PICUS';

  @override
  String get reportsFilterFieldSicTime => 'Tiempo SIC';

  @override
  String get reportsFilterFieldDualTime => 'Tiempo dual';

  @override
  String get reportsFilterFieldInstructorTime => 'Tiempo instructor';

  @override
  String get reportsFilterFieldCrossCountryTime => 'Tiempo travesia';

  @override
  String get reportsFilterFieldCustom1Time => 'Tiempo personalizado 1';

  @override
  String get reportsFilterFieldCustom2Time => 'Tiempo personalizado 2';

  @override
  String get reportsFilterFieldCustom3Time => 'Tiempo personalizado 3';

  @override
  String get reportsFilterFieldCustom4Time => 'Tiempo personalizado 4';

  @override
  String get reportsFilterFieldDistanceNm => 'Distancia NM';

  @override
  String get reportsFilterFieldTakeoffs => 'Despegues';

  @override
  String get reportsFilterFieldTakeoffsDay => 'Despegues dia';

  @override
  String get reportsFilterFieldTakeoffsNight => 'Despegues noche';

  @override
  String get reportsFilterFieldLandings => 'Aterrizajes';

  @override
  String get reportsFilterFieldLandingsDay => 'Aterrizajes dia';

  @override
  String get reportsFilterFieldLandingsNight => 'Aterrizajes noche';

  @override
  String get reportsFilterFieldIfrApproaches => 'Aproximaciones IFR';

  @override
  String get reportsFilterFieldMultiPilot => 'Multipiloto';

  @override
  String get reportsFilterFieldSimulator => 'Simulador';

  @override
  String get reportsFilterOperatorContains => 'Contiene';

  @override
  String get reportsFilterOperatorDoesNotContain => 'No contiene';

  @override
  String get reportsFilterOperatorStartsWith => 'Empieza con';

  @override
  String get reportsFilterOperatorDoesNotStartWith => 'No empieza con';

  @override
  String get reportsFilterOperatorEndsWith => 'Termina con';

  @override
  String get reportsFilterOperatorDoesNotEndWith => 'No termina con';

  @override
  String get reportsFilterOperatorIs => 'Es';

  @override
  String get reportsFilterOperatorIsNot => 'No es';

  @override
  String get reportsFilterOperatorGreaterThan => 'Mayor que';

  @override
  String get reportsFilterOperatorLessThan => 'Menor que';

  @override
  String get reportsFilterOperatorEquals => 'Igual a';

  @override
  String get reportsFilterOperatorIsTrue => 'Es verdadero';

  @override
  String get reportsFilterOperatorIsFalse => 'Es falso';

  @override
  String get languageLatvian => 'Letón';

  @override
  String get reportsAnalyzeByAirport => 'Por aeropuerto';

  @override
  String get reportsAnalyzeByPilot => 'Por piloto';

  @override
  String get reportsUnknownAirport => 'Aeropuerto desconocido';

  @override
  String get reportsUnknownPilot => 'Piloto desconocido';

  @override
  String get reportsOrderByHours => 'Horas';

  @override
  String get reportsOrderByLandings => 'Aterrizajes';

  @override
  String get reportsOrderByTakeoff => 'Despegues';

  @override
  String get reportsOrderByOperations => 'Operaciones';

  @override
  String get reportsMetricTakeoff => 'Despegues';

  @override
  String get reportsMetricOperations => 'Operaciones';

  @override
  String get aircraftFiltersTitle => 'Filtros de aeronaves';

  @override
  String get crewFiltersTitle => 'Filtros de tripulación';

  @override
  String get airportFiltersTitle => 'Filtros de aeropuertos';

  @override
  String get searchByLabel => 'Buscar por';

  @override
  String get orderByLabel => 'Ordenar por';

  @override
  String get optionAll => 'Todos';

  @override
  String get searchFieldType => 'Tipo';

  @override
  String get applyAction => 'Aplicar';

  @override
  String get fieldTakeoffs => 'Despegues';

  @override
  String get fieldLandings => 'Aterrizajes';

  @override
  String get fieldVisits => 'Operaciones';

  @override
  String get airportShowOnlyVisited => 'Mostrar solo aeropuertos visitados';

  @override
  String get airportSearchIcaoOrIata => 'ICAO o IATA';

  @override
  String get summaryFirstFlight => 'Primer vuelo';

  @override
  String get summaryLastFlight => 'Último vuelo';

  @override
  String get summaryTotalTime => 'Tiempo total';

  @override
  String get summaryTotalPic => 'Total PIC';

  @override
  String get notAvailableShort => '-';

  @override
  String get fieldCrew => 'Tripulación';

  @override
  String get addCrewTitle => 'Agregar tripulación';

  @override
  String get selectCrewTitle => 'Seleccionar tripulación';

  @override
  String get crewPositionLabel => 'Posición';

  @override
  String get crewPositionPic => 'PIC';

  @override
  String get crewPositionPicus => 'PICUS';

  @override
  String get crewPositionSic => 'SIC';

  @override
  String get crewPositionTrainee => 'Aprendiz';

  @override
  String get crewPositionInstructor => 'Instructor';

  @override
  String get crewPositionObserver => 'Observador';

  @override
  String get crewPositionRelief => 'Relevo';

  @override
  String get crewPositionReliefCaptain => 'Capitán de relevo';

  @override
  String get crewPositionReliefFirstOfficer => 'Primer oficial de relevo';

  @override
  String get crewPositionCabinSenior => 'Cabina senior';

  @override
  String get crewPositionCabinCrew => 'Tripulación de cabina';

  @override
  String get crewPositionOther => 'Otro';

  @override
  String get crewPositionUnknown => 'Desconocido';

  @override
  String get searchRegistration => 'Buscar matrícula';

  @override
  String get searchType => 'Buscar tipo';

  @override
  String get searchFamily => 'Buscar familia';

  @override
  String get searchNotes => 'Buscar notas';

  @override
  String get searchName => 'Buscar nombre';

  @override
  String get searchCity => 'Buscar ciudad';

  @override
  String get searchCountry => 'Buscar país';

  @override
  String get searchIcao => 'Buscar ICAO';

  @override
  String get searchIata => 'Buscar IATA';

  @override
  String get searchIcaoIata => 'Buscar ICAO/IATA';

  @override
  String get createSimulatorTitle => 'Agregar simulador';

  @override
  String get mapTitle => 'Mapa';

  @override
  String get aircraftEmptyResults => 'No se encontraron aeronaves';

  @override
  String get crewEmptyResults => 'No se encontró tripulación';

  @override
  String get crewLoadError => 'Error al cargar la tripulación';

  @override
  String get airportEmptyResults => 'No se encontraron aeropuertos';

  @override
  String get airportLoadError => 'Error al cargar aeropuertos';

  @override
  String get errorLabel => 'Error';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get dashboardNoActiveRules => 'No hay reglas activas configuradas.';

  @override
  String get dashboardRuleTotals => 'Totales de la regla';

  @override
  String get dashboardNoData => 'Sin datos.';

  @override
  String get dashboardEventsInCalculation => 'Eventos en el cálculo';

  @override
  String get dashboardNoEventsInWindow => 'No hay eventos en esta ventana.';

  @override
  String get dashboardFlightsLabel => 'Vuelos';

  @override
  String get dashboardBlockLabel => 'Block';

  @override
  String get dashboardFlightLabel => 'Vuelo';

  @override
  String get dashboardNightLabel => 'Noche';

  @override
  String get dashboardIfrLabel => 'IFR';

  @override
  String get dashboardInstrumentLabel => 'Instrumento';

  @override
  String get dashboardDutyLabel => 'Servicio';

  @override
  String get dashboardLandingsLabel => 'Aterrizajes';

  @override
  String get dashboardSetupTitle => 'Configuración del panel';

  @override
  String get dashboardAddRule => 'Agregar regla';

  @override
  String get dashboardNoRulesConfigured => 'No hay reglas configuradas.';

  @override
  String get dashboardEditRuleTitle => 'Editar regla';

  @override
  String get dashboardCreateRuleTitle => 'Crear regla';

  @override
  String get dashboardRuleNameLabel => 'Nombre de la regla';

  @override
  String get dashboardMetricLabel => 'Métrica';

  @override
  String get dashboardRuleTypeLabel => 'Tipo de regla';

  @override
  String get dashboardWindowTypeLabel => 'Tipo de ventana';

  @override
  String get dashboardStartReferenceLabel => 'Referencia de inicio';

  @override
  String get dashboardWindowValueLabel => 'Valor de ventana';

  @override
  String get dashboardLimitValueLabel => 'Valor límite';

  @override
  String get dashboardUnitLabel => 'Unidad';

  @override
  String get dashboardWarnYellowBeforeLabel => 'Aviso amarillo antes';

  @override
  String get dashboardWarnRedBeforeLabel => 'Aviso rojo antes';

  @override
  String get dashboardCreateAction => 'Crear';

  @override
  String get dashboardTakeoffLabel => 'Despegue';

  @override
  String get dashboardTakeoffDayLabel => 'Despegue diurno';

  @override
  String get dashboardTakeoffNightLabel => 'Despegue nocturno';

  @override
  String get dashboardLandingsDayLabel => 'Aterrizajes diurnos';

  @override
  String get dashboardLandingsNightLabel => 'Aterrizajes nocturnos';

  @override
  String get dashboardInstrumentApproachesLabel =>
      'Aproximaciones instrumentales';

  @override
  String get dashboardPicTimeLabel => 'Tiempo PIC';

  @override
  String get dashboardSicTimeLabel => 'Tiempo SIC';

  @override
  String get dashboardPicusTimeLabel => 'Tiempo PICUS';

  @override
  String get dashboardDualTimeLabel => 'Tiempo dual';

  @override
  String get dashboardInstructorTimeLabel => 'Tiempo instructor';

  @override
  String get dashboardCrossCountryLabel => 'Travesía';

  @override
  String get dashboardMinimumLabel => 'Mínimo';

  @override
  String get dashboardMaximumLabel => 'Máximo';

  @override
  String get dashboardHoursUnit => 'horas';

  @override
  String get dashboardMinutesUnit => 'minutos';

  @override
  String get dashboardDaysUnit => 'días';

  @override
  String get dashboardWeeksUnit => 'semanas';

  @override
  String get dashboardMonthsUnit => 'meses';

  @override
  String get dashboardYearsUnit => 'años';

  @override
  String get dashboardCountUnit => 'conteo';

  @override
  String get dashboardCalendarMonthsLabel => 'Meses calendario';

  @override
  String get dashboardCalendarYearsLabel => 'Años calendario';

  @override
  String get dashboardCalendarDaysLabel => 'Días calendario';

  @override
  String get dashboardCalendarQuarterLabel => 'Trimestre calendario';

  @override
  String get dashboardSameTimeNowLabel => 'Misma hora (ahora)';

  @override
  String get dashboardMidnightLocalLabel => 'Medianoche local';

  @override
  String get dashboardMidnightUtcLabel => 'Medianoche UTC';

  @override
  String get dashboardRemainingSuffix => 'restante';

  @override
  String get dashboardOverLimitSuffix => 'sobre el límite';

  @override
  String get dashboardAboveMinimumSuffix => 'por encima del mínimo';

  @override
  String get dashboardBelowMinimumSuffix => 'por debajo del mínimo';

  @override
  String get dashboardMinimumShortLabel => 'Mín';

  @override
  String get dashboardMaximumShortLabel => 'Máx';

  @override
  String get dashboardSameTimeLabel => 'Misma hora';

  @override
  String get checkFactoringRulesTitle => 'Revisar reglas de cálculo';

  @override
  String get continueSavingQuestion => '¿Continuar guardando?';

  @override
  String get reviewAction => 'Revisar';

  @override
  String get saveAnywayAction => 'Guardar de todos modos';

  @override
  String get createFlightTitle => 'Nuevo vuelo';

  @override
  String get editFlightTitle => 'Editar vuelo';

  @override
  String get calculateAction => 'Calcular';

  @override
  String get nextAction => 'Siguiente';

  @override
  String get fieldDate => 'Fecha';

  @override
  String get fieldPilotFunction => 'Función del piloto';

  @override
  String get chocksOffRequiredToCalculate =>
      'Se requiere Chocks OFF para calcular.';

  @override
  String get chocksOnRequiredToCalculate =>
      'Se requiere Chocks ON para calcular.';

  @override
  String get clearAction => 'Limpiar';

  @override
  String get fieldRemarks => 'Observaciones';

  @override
  String get noCrewAssigned => 'Sin tripulación asignada';

  @override
  String get removeAction => 'Quitar';

  @override
  String get eventInfoTitle => 'Información del evento';

  @override
  String get clearDatabaseTitle => 'Borrar base de datos';

  @override
  String get clearDatabaseMessage =>
      'Esto eliminará todos los datos y recreará tablas vacías.';
}
