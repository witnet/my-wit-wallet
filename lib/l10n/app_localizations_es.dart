// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get address => 'Dirección';

  @override
  String get addressBalanceDescription => 'Recibió pagos por un total de';

  @override
  String get addressCopied => '¡Dirección copiada!';

  @override
  String get addressList => 'Lista de direcciones';

  @override
  String get addTimelockLabel => 'Añadir Timelock (Opcional)';

  @override
  String get advancedSettings => 'Configuración avanzada';

  @override
  String get amount => 'Cantidad';

  @override
  String get authenticateWithBiometrics => 'Autenticación biométrica';

  @override
  String get authorization => 'Autorización del nodo';

  @override
  String get authorizationInputHint => 'Autorización del nodo...';

  @override
  String get autorizationTooltip =>
      'Autorización del nodo para realizar staking';

  @override
  String get available => 'Disponible';

  @override
  String get backLabel => 'Volver';

  @override
  String get balance => 'saldo';

  @override
  String get balanceDetails => 'Saldo en detalle';

  @override
  String get biometricsLabel => 'Biométricas';

  @override
  String get blocksMined => 'Bloques extraídos';

  @override
  String get buildWallet01 =>
      'Se están escaneando las diferentes direcciones de tu cartera en busca de transacciones y saldo existentes. Esto normalmente tomará menos de 1 minuto.';

  @override
  String get buildWalletBalance => 'Saldo';

  @override
  String get buildWalletHeader => 'Descubrimiento de direcciones';

  @override
  String get cancel => 'Cancelar';

  @override
  String get cancelAuthentication => 'Cancelar autentificación';

  @override
  String get carouselMsg01 =>
      'myWitWallet te permite enviar y recibir Wit al instante. ¡Adiós a la sincronización!';

  @override
  String get carouselMsg02 =>
      'myWitWallet utiliza la criptografía de última generación para almacenar tus monedas Wit de manera segura.';

  @override
  String get carouselMsg03 =>
      'myWitWallet es completamente no custodial. Tus claves nunca saldrán de tu dispositivo.';

  @override
  String get chooseMinerFee => 'Elija la tasa minera que desee';

  @override
  String get clearTimelockLabel => 'Borrar Timelock';

  @override
  String get clickToInstall => 'Haz clic para instalar.';

  @override
  String get close => 'cerrar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get confirmed => 'Confirmada';

  @override
  String get confirmMnemonic01 =>
      'Escribe tu frase de recuperación secreta a continuación exactamente como se muestra. Esto asegurará que hayas escrito tu frase de recuperación secreta correctamente.';

  @override
  String get confirmMnemonicHeader =>
      'Confirmación de la frase de recuperación secreta';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get connectionIssue =>
      'myWitWallet está experimentando problemas de conexión';

  @override
  String get connectionReestablished => '¡Conexión restablecida!';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get copyAddressConfirmed => '¡Dirección copiada!';

  @override
  String get copyAddressLabel => 'Copiar dirección seleccionada';

  @override
  String get copyAddressToClipboard => 'Copiar dirección en el portapapeles';

  @override
  String get copyJson => 'Copiar JSON';

  @override
  String get copyStakingAddress => 'Copiar dirección de retiro';

  @override
  String get copyXprvConfirmed => '¡Xprv copiado!';

  @override
  String get copyXprvLabel => 'Copiar Xprv';

  @override
  String get createImportWallet01 =>
      'Cuando creaste tu cartera, probablemente escribiste la frase de seguridad secreta en un papel. Parece una lista de 12 palabras aparentemente aleatorias.';

  @override
  String get createImportWallet02 =>
      'Si no conservaste la frase de seguridad secreta, aún puedes exportar una clave Xprv protegida con contraseña desde la configuración de tu cartera existente.';

  @override
  String get createImportWalletHeader => 'Crear o importar tu cartera';

  @override
  String get createNewWalletLabel => 'Crear nueva cartera';

  @override
  String get createOrImportLabel => 'Crear o importar';

  @override
  String get createWalletLabel => 'Crear cartera';

  @override
  String get cryptoException => 'Error creando el wallet';

  @override
  String get currentAddress => 'dirección actual';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String dashboardViewSteps(String selectedIndex) {
    String _temp0 = intl.Intl.selectLogic(
      selectedIndex,
      {
        'transactions': 'Transacciones',
        'stats': 'Estadísticas',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get dataRequestTxn => 'Data Request';

  @override
  String get datePickerFormatError => 'Formato de fecha no válido';

  @override
  String get datePickerHintText => 'Seleccionar fecha';

  @override
  String get datePickerInvalid => 'Fecha no válida';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteStorageWarning =>
      'Tu almacenamiento está a punto de ser eliminado permanentemente.';

  @override
  String get deleteWallet => 'Eliminar wallet';

  @override
  String get deleteWallet01 =>
      'Hacer clic en \"Eliminar\" resultará en la eliminación permanente de los datos de tu wallet actual. Si procedes, deberás importar la wallet nuevamente para acceder a tus fondos.';

  @override
  String get deleteWalletSettings => 'Configuración: Eliminar wallet';

  @override
  String get deleteWalletSuccess =>
      '¡Los datos de tu wallet han sido eliminados exitosamente!';

  @override
  String get deleteWalletWarning =>
      '¡Tu wallet está a punto de ser eliminada permanentemente!';

  @override
  String get disableStakeMessage =>
      'La cantidad minima para hacer Stake es de 10.000 WIT';

  @override
  String get disableStakeTitle =>
      'No tienes suficiente balance para hacer Stake';

  @override
  String get downloading => 'Descargando...';

  @override
  String get drSolved => 'Solicitudes de datos resueltas';

  @override
  String get emptyStakeMessage =>
      '¡Haz stake de algunos \$WIT! Asegura la red, gana recompensas y forma parte de un oráculo resistente a la censura.';

  @override
  String get emptyStakeTitle => 'No tienes saldo para retirar stake';

  @override
  String get enableLoginWithBiometrics =>
      'Inicio de sesión con datos biométricos';

  @override
  String get encryptWallet01 =>
      'Esta contraseña encripta tu cartera Witnet solo en esta computadora.';

  @override
  String get encryptWallet02 =>
      'Esta no es tu copia de seguridad y no puedes restaurar tu cartera con esta contraseña.';

  @override
  String encryptWallet03(int mnemonicLength) {
    return 'Tu frase de recuperación de $mnemonicLength palabras sigue siendo tu método de recuperación definitivo.';
  }

  @override
  String get encryptWallet04 =>
      'Your Xprv is still your ultimate recovery method.';

  @override
  String get encryptWalletHeader => 'Encripta tu cartera';

  @override
  String get enterYourPassword => 'Escriba su contraseña';

  @override
  String get epoch => 'Época';

  @override
  String get error => 'Error';

  @override
  String get errorDeletingWallet =>
      '¡Hubo un error al eliminar la wallet, por favor inténtalo de nuevo!';

  @override
  String get errorFieldBlank => 'Field is blank';

  @override
  String get errorReestablish =>
      'Se ha producido un error al restablecer myWitWallet, inténtalo de nuevo.';

  @override
  String get errorSigning => 'Mensaje de error al firmar';

  @override
  String get errorTransaction =>
      'Error al enviar la transacción, ¡inténtelo de nuevo!';

  @override
  String get errorTryAgain => 'Error. Inténtalo de nuevo.';

  @override
  String get errorXprvStart => 'needs to start with \\\"xprv1\\\"';

  @override
  String estimatedFeeOptions(String feeOption) {
    String _temp0 = intl.Intl.selectLogic(
      feeOption,
      {
        'stinky': 'Apestoso',
        'low': 'Bajo',
        'medium': 'Medio',
        'high': 'High',
        'opulent': 'Alta',
        'custom': 'A medida',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get exploredAddresses => 'Direcciones exploradas';

  @override
  String get exploringAddress => 'Explorando dirección:';

  @override
  String get exportJson => 'Exportar JSON';

  @override
  String get exportXprv => 'Exportar Xprv';

  @override
  String get fee => 'Tasa';

  @override
  String get feesAndRewards => 'Tasas y Recompensas';

  @override
  String get feesCollected => 'Comisiones cobradas';

  @override
  String get feesPayed => 'Comisiones pagadas';

  @override
  String feeTypeOptions(String feeType) {
    String _temp0 = intl.Intl.selectLogic(
      feeType,
      {
        'absolute': 'Absoluto',
        'weighted': 'Ponderado',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get forgetPassword =>
      '¿Has olvidado tu contraseña?, ¡Puedes borrar tu monedero y configurar uno nuevo!';

  @override
  String get from => 'de';

  @override
  String get generateAddressWarning =>
      'Estás a punto de generar una nueva dirección';

  @override
  String get generateAddressWarningMessage =>
      'Una nueva dirección estará disponible para su uso. La dirección mostrada en la barra de navegación se actualizará a la nueva dirección generada.';

  @override
  String get generatedAddress => 'Dirección generada';

  @override
  String get generatedAddresses => 'Direcciones generadas';

  @override
  String generateMnemonic01(int mnemonicLength) {
    return 'Estas $mnemonicLength palabras aparentemente aleatorias son tu frase de recuperación secreta. Te permitirán recuperar tus monedas Wit si desinstalas esta aplicación o olvidas la contraseña de bloqueo de tu cartera.';
  }

  @override
  String get generateMnemonic02 =>
      'Debes escribir tu frase de recuperación secreta en un papel y almacenarla en un lugar seguro. No la almacenes en un archivo en tu dispositivo ni en ningún otro lugar electrónico. Si pierdes tu frase de recuperación secreta, podrías perder permanentemente el acceso a tu cartera y tus monedas Wit.';

  @override
  String get generateMnemonic03 =>
      'Nunca debes compartir tu frase de recuperación secreta con nadie. Si alguien encuentra o ve tu frase de recuperación secreta, tendrá acceso completo a tu cartera y tus monedas Wit.';

  @override
  String get generateMnemonicHeader =>
      'Escribe tu frase de recuperación secreta';

  @override
  String get generateXprv => 'Generar Xprv';

  @override
  String get genNewAddressLabel => 'Generar nueva dirección';

  @override
  String get history => 'Historia';

  @override
  String get home => 'Lista de transacciones';

  @override
  String get hour => 'Hora';

  @override
  String get importMnemonic01 =>
      'Escribe tu frase de recuperación secreta a continuación. Parece una lista de 12 palabras aparentemente aleatorias.';

  @override
  String get importMnemonicHeader =>
      'Importar cartera desde la frase de recuperación secreta';

  @override
  String get importMnemonicLabel =>
      'Importar cartera desde la frase de recuperación secreta';

  @override
  String get importWalletHeader => '';

  @override
  String get importWalletLabel => 'Importar cartera';

  @override
  String get importXprv01 =>
      'Xprv es un formato de intercambio de claves que codifica y protege tu cartera con una contraseña. Las claves Xprv se ven como una larga secuencia de letras y números aparentemente aleatorios, precedidos por \"xprv\".';

  @override
  String get importXprv02 =>
      'Para importar tu cartera desde una clave Xprv encriptada con una contraseña, debes escribir la clave misma y su contraseña a continuación:';

  @override
  String get importXprvHeader => 'Importar cartera desde una clave Xprv';

  @override
  String get importXprvLabel => 'Importar desde la clave Xprv';

  @override
  String get initializingWallet => 'Inicializando cartera.';

  @override
  String get inputAmountHint => 'Ingresar un monto';

  @override
  String get inputPasswordPrompt =>
      'Por favor, ingresa la contraseña de tu cartera.';

  @override
  String get inputs => 'Insumos';

  @override
  String get inputYourPassword => 'Ingresa tu contraseña';

  @override
  String get insufficientFunds => 'Fondos insuficientes';

  @override
  String get insufficientUtxosAvailable =>
      'Espera a la confirmación de las transacciones pendientes o crea una transacción con una cantidad más pequeña.';

  @override
  String get internalBalance => 'Saldo interno';

  @override
  String get internalBalanceHint =>
      'El saldo interno corresponde a la suma del saldo disponible en todas las cuentas de cambio';

  @override
  String get invalidPassword => 'Contraseña inválida';

  @override
  String get invalidXprv => 'Xprv inválido:';

  @override
  String get invalidXprvBlank => 'El campo está en blanco';

  @override
  String get invalidXprvStart => 'debe comenzar con \"xprv1\"';

  @override
  String get jsonCopied => 'JSON copiado!';

  @override
  String get later => 'Más tarde';

  @override
  String launchUrlError(String error) {
    return 'No se pudo abrir $error';
  }

  @override
  String get lightMode => 'Modo claro';

  @override
  String get loading => 'Cargando';

  @override
  String get locked => 'Bloqueado';

  @override
  String get lockWalletLabel => 'Bloquear cartera';

  @override
  String get lockYourWallet => 'Bloquea tu cartera';

  @override
  String get messageSigning => 'Firma de mensajes';

  @override
  String get messageSigning01 =>
      'Demuestre la propiedad de su dirección añadiendo su firma a un mensaje.';

  @override
  String get messageToBeSigned => 'Mensaje a firmar';

  @override
  String get mined => 'Minada';

  @override
  String get minerFeeHint =>
      'Por defecto, la tarifa Absoluta está seleccionada. La comisión ponderada la calcula automáticamente el monedero teniendo en cuenta la congestión de la red y el peso de la transacción multiplicado por el valor seleccionado como personalizado.';

  @override
  String get minerFeeInputHint => 'Introduzca la tasa minera';

  @override
  String get mintTxn => 'Mint';

  @override
  String get minutes => 'Minutos';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get networkContribution => 'Contribución a la red';

  @override
  String newVersion(Object versionNumber) {
    return 'Nueva versión: $versionNumber';
  }

  @override
  String get newVersionAvailable => 'Nueva versión disponible.';

  @override
  String get noTransactions => '¡Aún no tienes transacciones!';

  @override
  String get okLabel => 'Aceptar';

  @override
  String get outputs => 'Salidas';

  @override
  String get passwordDescription =>
      'Esta contraseña encripta tu archivo xprv. Se te pedirá que ingreses esta contraseña si deseas importar este xprv como copia de seguridad.';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get pending => 'Pendiente';

  @override
  String get pleaseWait => 'Por favor, espera...';

  @override
  String preferenceTabs(String selectedTab) {
    String _temp0 = intl.Intl.selectLogic(
      selectedTab,
      {
        'general': 'General',
        'wallet': 'Cartera',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get readCarefully =>
      'Por favor, lea atentamente antes de continuar. Su atención es crucial.';

  @override
  String get readyToInstall => 'Listo para instalar.';

  @override
  String get receive => 'Recibir';

  @override
  String get recipientAddress => 'Dirección del receptor';

  @override
  String get reestablish => 'Restablecer';

  @override
  String get reestablishInstructions =>
      'Al hacer clic en \"Continuar\" se eliminarán permanentemente los datos de su monedero actual. Si continúa, tendrá que importar un monedero existente o crear uno nuevo para acceder a sus fondos.';

  @override
  String get reestablishSteps01 =>
      'Asegúrese de que ha almacenado su frase semilla de recuperación o Xprv.';

  @override
  String get reestablishSteps02 =>
      'Haga clic en \"Continuar\" para borrar su almacenamiento e importar su monedero de nuevo.';

  @override
  String get reestablishSucess => '¡myWitWallet se ha restablecido con éxito!';

  @override
  String get reestablishWallet => 'Restablecer cartera';

  @override
  String get reestablishYourWallet => 'Restablezca su cartera';

  @override
  String get reverted => 'Revertida';

  @override
  String get scanAqrCode => 'Escanear un código QR';

  @override
  String get scanQrCodeLabel => 'Escanear código QR';

  @override
  String get selectImportOptionHeader => 'Importar tu cartera';

  @override
  String get send => 'Enviar';

  @override
  String get sendReceiveTx => 'Enviar o recibir WIT';

  @override
  String get sendStakeTransaction => 'Transacción de Stake';

  @override
  String get sendUnstakeTransaction => 'Transacción de Unstake';

  @override
  String get sendValueTransferTransaction =>
      'Transacción de Transferencia de Valor';

  @override
  String get setTimelock => 'fijar bloqueo horario';

  @override
  String get settings => 'Ajustes';

  @override
  String get settingsMessageSigning => 'Configuración: Firma de mensajes';

  @override
  String get settingsWalletConfigHeader =>
      'Configuración: Exportar la clave Xprv de mi cartera';

  @override
  String get sheikah => 'Sheikah';

  @override
  String get showBalanceDetails => 'Mostrar detalles del balace';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get showWalletList => 'Mostrar lista de carteras';

  @override
  String get signAndSend => 'Firmar y enviar';

  @override
  String get signMessage => 'Signo Mensaje';

  @override
  String get signMessageError => 'Error firmando el mensaje';

  @override
  String get speedUp => 'Acelerar';

  @override
  String get speedUpTxTitle => 'Acelerar transacción';

  @override
  String get stake => 'Stake';

  @override
  String get staked => 'Staked';

  @override
  String stakeSteps(String currentStepIndex) {
    String _temp0 = intl.Intl.selectLogic(
      currentStepIndex,
      {
        'Transaction': 'Stake',
        'MinerFee': 'Miner Fee',
        'Review': 'Review',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get stakeTxnSuccess => '¡Transacción de stake enviada con éxito!';

  @override
  String get stakeUnstake => 'Stake o unstake WIT';

  @override
  String get stakeWithdrawalAddressText =>
      'This is the address to create Stake transactions. Make sure this address is authorized to stake.';

  @override
  String get stakingAddressCopied => '¡Dirección de retiro copiada!';

  @override
  String get status => 'Estado';

  @override
  String get theme => 'Tema';

  @override
  String get timelock => 'bloqueo temporizado';

  @override
  String get timelockTooltip =>
      'El beneficiario no podrá gastar las monedas antes de esa fecha y hora.';

  @override
  String get timePickerHintText => 'Hora fijada';

  @override
  String get timePickerInvalid => 'tiempo inválido';

  @override
  String get timestamp => 'Marca de tiempo';

  @override
  String get to => 'a';

  @override
  String get total => 'Total';

  @override
  String get totalDataSynced => 'Resumen de la sincronización';

  @override
  String get totalFeesPaid => 'Total de tasas pagadas';

  @override
  String get totalMiningRewards => 'Recompensas mineras totales';

  @override
  String get transaction => 'Transacción';

  @override
  String get transactionDetails => 'Detalles de la transacción';

  @override
  String get transactionId => 'ID de la transacción';

  @override
  String get transactionsFound => 'Transacciones encontradas';

  @override
  String get tryAgain => '¡Inténtalo de nuevo!';

  @override
  String get txEmptyState => '¡Todavía no tienes transacciones!';

  @override
  String get txnCheckStatus =>
      'Compruebe el estado de la transacción en el Explorador de bloques de Witnet:';

  @override
  String get txnDetails => 'Detalles de la transacción';

  @override
  String get txnSending => 'Transacción de envío';

  @override
  String get txnSending01 => 'La transacción se está enviando';

  @override
  String get txnSigning => 'Transacción de canto';

  @override
  String get txnSigning01 => 'Se está firmando la transacción';

  @override
  String txnStatus(String feeType) {
    String _temp0 = intl.Intl.selectLogic(
      feeType,
      {
        'pending': 'pendiente',
        'mined': 'minado',
        'confirmed': 'confirmado',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get txnSuccess => '¡Transacción enviada con éxito!';

  @override
  String get type => 'Tipo';

  @override
  String get unlockWallet => 'Desbloquear cartera';

  @override
  String get unstake => 'Unstake';

  @override
  String unstakeSteps(String currentStepIndex) {
    String _temp0 = intl.Intl.selectLogic(
      currentStepIndex,
      {
        'Transaction': 'Unstake',
        'MinerFee': 'Miner Fee',
        'Review': 'Review',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get unstakeTxnSuccess => '¡Transacción de unstake enviada con éxito!';

  @override
  String get unstakeWithdrawalAddressText =>
      'This is the address used to create Stake transactions.';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String get updateError =>
      'Hubo un problema con la actualización. Por favor, inténtalo de nuevo.';

  @override
  String get updateNow => 'Actualiza ahora';

  @override
  String updateToVersion(Object versionNumber) {
    return 'Actualizar a la versión $versionNumber';
  }

  @override
  String get validationDecimals => 'Solo se admiten 9 dígitos decimales';

  @override
  String get validationEmpty => 'Por favor, ingrese una cantidad';

  @override
  String get validationEnoughFunds => 'Fondos insuficientes';

  @override
  String get validationInvalidAmount => 'Cantidad inválida';

  @override
  String get validationMinFee => 'La tarifa de minado tiene que ser mayor que';

  @override
  String get validationNoZero => 'La cantidad no puede ser cero';

  @override
  String get validator => 'Validador';

  @override
  String get validatorDescription =>
      'Dirección del validador que autorizó el staking.';

  @override
  String get valueTransferTxn => 'Value Transfer';

  @override
  String get verifyLabel => 'Verificar';

  @override
  String versionNumber(String versionNumber) {
    return 'Versión $versionNumber';
  }

  @override
  String get viewOnExplorer => 'Ver en el Explorador de Bloques';

  @override
  String get vttException => 'Error creando la transacción';

  @override
  String vttSendSteps(String currentStepIndex) {
    String _temp0 = intl.Intl.selectLogic(
      currentStepIndex,
      {
        'Transaction': 'Transacción',
        'MinerFee': 'Minera cuota',
        'Review': 'La revisión',
        'other': 'unused',
      },
    );
    return '$_temp0';
  }

  @override
  String get walletConfig01 =>
      'Tu clave Xprv te permite exportar y hacer una copia de seguridad de tu cartera en cualquier momento después de crearla.';

  @override
  String get walletConfig02 =>
      'En términos de privacidad, tu clave Xprv es equivalente a una frase de recuperación secreta. No la compartas con nadie y nunca la almacenes en un archivo en tu dispositivo ni en ningún otro lugar electrónico.';

  @override
  String get walletConfig03 =>
      'Tu clave Xprv estará protegida con la contraseña a continuación. Al importar la clave Xprv en esta u otra aplicación, se te pedirá que escribas esa misma contraseña.';

  @override
  String get walletConfigHeader => 'Exportar la clave Xprv de mi cartera';

  @override
  String get walletDetail01 =>
      'Puedes hacer un mejor seguimiento de tus diferentes carteras dándoles a cada una su propio nombre y descripción.';

  @override
  String get walletDetail02 =>
      'Los nombres de las carteras facilitan cambiar rápidamente de una cartera a otra. Las descripciones de las carteras pueden ser más detalladas y describir el propósito de una cartera u otros metadatos.';

  @override
  String get walletDetailHeader => 'Identifica tu cartera';

  @override
  String get walletNameHint => 'Mis primeros millones de Wits';

  @override
  String get walletSecurity01 =>
      'Por favor, lee con atención antes de continuar.';

  @override
  String get walletSecurity02 =>
      'Una cartera es una aplicación que mantiene seguras tus credenciales y te permite interactuar con la cadena de bloques de Witnet. Te permite transferir y recibir Wit de manera sencilla.';

  @override
  String get walletSecurity03 =>
      'Nunca debes compartir tu frase de recuperación con nadie. Nosotros en Witnet no almacenamos tu frase de recuperación y nunca te pediremos que la compartas con nosotros. Si pierdes tu frase de recuperación, perderás permanentemente el acceso a tu cartera y a tus fondos.';

  @override
  String get walletSecurity04 =>
      'Si alguien encuentra o ve tu frase de recuperación, tendrá acceso a tu cartera y a todos tus fondos.';

  @override
  String get walletSecurity05 =>
      'Recomendamos almacenar tu frase de recuperación en papel en un lugar seguro. No la almacenes en un archivo en tu computadora ni en ningún lugar electrónico.';

  @override
  String get walletSecurity06 =>
      'Al aceptar estos avisos, te comprometes a cumplir con las restricciones explicadas y a firmar digitalmente tu conformidad utilizando tu cartera de Witnet.';

  @override
  String get walletSecurityConfirmLabel => '¡Seré cuidadoso, lo prometo!';

  @override
  String get walletSecurityHeader => 'Seguridad de la cartera';

  @override
  String get walletTypeHDLabel => 'HD Cartera';

  @override
  String get walletTypeNodeLabel => 'Nodo';

  @override
  String get welcome => 'Bienvenido';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get whatToDo => '¿Qué hacer?';

  @override
  String get withdrawer => 'Dirección de retiro';

  @override
  String get withdrawalAddress => 'Dirección de retiro';

  @override
  String get xprvInputHint => 'Tu clave Xprv (comienza con xprv...)';

  @override
  String get xprvOrigin => 'Origen de Xprv';

  @override
  String get yourMessage => 'Tu mensaje...';
}
