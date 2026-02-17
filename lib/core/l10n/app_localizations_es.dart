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
}
