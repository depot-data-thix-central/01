import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String personalReg = '/personal-reg';
  static const String enterpriseReg = '/enterprise-reg';
  static const String enterprise = '/enterprise';
  static const String payment = '/payment';
  static const String activationReceipt = '/activation-receipt';
  static const String publicProfile = '/public-profile';
  static const String userDashboard = '/user-dashboard';
  static const String enterpriseDashboard = '/enterprise-dashboard';
  static const String enterprisePortalBasePath = '/company';
  static String enterprisePortalBase(String slug) => '$enterprisePortalBasePath/$slug';
  static String enterprisePortalDashboard(String slug, String section) =>
      '${enterprisePortalBase(slug)}/dashboard/$section';

  static const String chat = '/chat';
  static const String chatConversation = '/chat/conversation';
  static const String ephemeralSettings = '/chat/ephemeral-settings';
  static const String translationSettings = '/chat/translation-settings';
  static const String chatThemes = '/chat/themes';
  static const String bubbleCustomizer = '/chat/bubble-customizer';
  static const String notificationSounds = '/chat/notification-sounds';
  static const String chatWallpaper = '/chat/wallpaper';
  static const String fontSize = '/chat/font-size';
  static const String themePreview = '/chat/theme-preview';
  static const String statusSettings = '/chat/status-settings';
  static const String availabilitySchedule = '/chat/availability-schedule';
  static const String statusPresets = '/chat/status-presets';
  static const String chatArchive = '/chat/archive';
  static const String exportChat = '/chat/export';
  static const String dataSaver = '/chat/data-saver';
  static const String widgetsConfig = '/chat/widgets-config';
  static const String widgetsPreview = '/chat/widgets-preview';
  static const String chatCall = '/chat/call';
  static const String chatIncomingCall = '/chat/incoming-call';
  static const String chatStatus = '/chat/status';
  static const String chatStatusUpdate = '/chat/status-update';
  static const String chatSpaces = '/chat/spaces';

  static const String messages = '/messages';
  static const String profile = '/profile';
  static const String vault = '/vault';
  static const String settings = '/settings';

  static const String networkPro = '/network';
  static const String networkProfile = '/network/member';
  static const String networkPost = '/network/post';
  static const String networkSearch = '/network/search';
  static const String networkCommunity = '/network/community';
  static const String networkSettings = '/network/settings';
  static const String networkBlocked = '/network/blocked';
  static const String networkGroups = '/network/groups';
  static const String networkMessages = '/network/messages';
  static const String networkChat = '/network/chat';
  static const String networkNotifications = '/network/notifications';
  static const String networkConnections = '/network/connections';
  static const String networkMyPosts = '/network/my-posts';
  static const String networkReels = '/network/reels';
  static const String networkHashtag = '/network/hashtag';
  static const String networkSaved = '/network/saved';
  static const String networkReposted = '/network/reposted';
  static const String networkProfileSettings = '/network/profile-settings';
  static const String networkFollowers = '/network/followers';
  static const String networkFollowing = '/network/following';
  static const String networkLiked = '/network/liked';
  static const String networkProfilePage = '/network/profile-page';

  static const String thixEvent = '/thix-event';
  static const String thixEventDetail = '/thix-event/detail';
  static const String thixEventSearch = '/thix-event/search';
  static const String thixEventCategory = '/thix-event/category';
  static const String thixEventReservation = '/thix-event/reservation';
  static const String thixEventMyTickets = '/thix-event/my-tickets';
  static const String thixEventFavorites = '/thix-event/favorites';
  static const String thixEventSeatSelection = '/thix-event/seat-selection';
  static const String thixEventWaitingQueue = '/thix-event/waiting-queue';

  static const String patientHome = '/sante/patient';
  static const String patientTracking = '/sante/patient/tracking';
  static const String patientAppointments = '/sante/patient/appointments';
  static const String patientMedicalRecord = '/sante/patient/medical-record';
  static const String patientMessages = '/sante/patient/messages';
  static const String patientProfile = '/sante/patient/profile';
  static const String patientSettings = '/sante/patient/settings';
  static const String patientFamily = '/sante/patient/family';
  static const String patientConsents = '/sante/patient/consents';
  static const String patientNotifications = '/sante/patient/notifications';

  static const String doctorHome = '/sante/doctor';
  static const String doctorPatients = '/sante/doctor/patients';
  static const String doctorPatientDetail = '/sante/doctor/patient-detail';
  static const String doctorPrescription = '/sante/doctor/prescription';
  static const String doctorTeleconsultation = '/sante/doctor/teleconsultation';
  static const String doctorTeleexpertise = '/sante/doctor/teleexpertise';
  static const String doctorSchedule = '/sante/doctor/schedule';
  static const String doctorMessages = '/sante/doctor/messages';
  static const String doctorProfile = '/sante/doctor/profile';
  static const String doctorAnalytics = '/sante/doctor/analytics';
  static const String doctorNotes = '/sante/doctor/notes';

  static const String pharmacyHome = '/sante/pharmacy';
  static const String pharmacyOrders = '/sante/pharmacy/orders';
  static const String pharmacyInventory = '/sante/pharmacy/inventory';
  static const String pharmacyDelivery = '/sante/pharmacy/delivery';
  static const String pharmacyPrescriptionDetail = '/sante/pharmacy/prescription';
  static const String pharmacyMessages = '/sante/pharmacy/messages';
  static const String pharmacyProfile = '/sante/pharmacy/profile';
  static const String pharmacyReports = '/sante/pharmacy/reports';

  static const String thixInfo = '/thix-info';
  static const String thixInfoArticle = '/thix-info/article';
  static const String thixInfoSearch = '/thix-info/search';
  static const String thixInfoCategory = '/thix-info/category';
  static const String thixInfoSaved = '/thix-info/saved';
  static const String thixInfoBreaking = '/thix-info/breaking';
  static const String thixInfoAdmin = '/admin/news';
  static const String thixInfoCreate = '/admin/news/create';

  static const String thixMarket = '/thix-market';
  static const String thixMedia = '/thix-media';
  static const String thixSante = '/thix-sante';
  static const String thixMoney = '/thix-money';

  static const String thixMoneyCards = '/thix-money/cards';
  static const String thixMoneyCreateTontine = '/thix-money/create-tontine';
  static const String thixMoneyCredit = '/thix-money/credit';
  static const String thixMoneyCreditRequest = '/thix-money/credit-request';
  static const String thixMoneyDeposit = '/thix-money/deposit';
  static const String thixMoneyGroupSavings = '/thix-money/group-savings';
  static const String thixMoneyHistory = '/thix-money/history';
  static const String thixMoneyInsurance = '/thix-money/insurance';
  static const String thixMoneyInternationalTransfer = '/thix-money/international-transfer';
  static const String thixMoneyInvestment = '/thix-money/investment';
  static const String thixMoneyNotifications = '/thix-money/notifications';
  static const String thixMoneyProfile = '/thix-money/profile';
  static const String thixMoneySavings = '/thix-money/savings';
  static const String thixMoneyScanner = '/thix-money/scanner';
  static const String thixMoneyServices = '/thix-money/services';
  static const String thixMoneyTontine = '/thix-money/tontine';
  static const String thixMoneyTransactions = '/thix-money/transactions';
  static const String thixMoneyTransfer = '/thix-money/transfer';
  static const String thixMoneyWithdraw = '/thix-money/withdraw';

  static const String reservation = '/reservation';
  static const String reservationVols = '/reservation/vols';
  static const String reservationVolsRecherche = '/reservation/vols/recherche';
  static const String reservationVolsListe = '/reservation/vols/liste';
  static const String reservationVolsDetails = '/reservation/vols/details';
  static const String reservationVolsPassagers = '/reservation/vols/passagers';
  static const String reservationVolsPaiement = '/reservation/vols/paiement';
  static const String reservationVolsConfirmation = '/reservation/vols/confirmation';
  static const String reservationHotels = '/reservation/hotels';
  static const String reservationHotelsRecherche = '/reservation/hotels/recherche';
  static const String reservationHotelsListe = '/reservation/hotels/liste';
  static const String reservationHotelsDetails = '/reservation/hotels/details';
  static const String reservationHotelsReservation = '/reservation/hotels/reservation';
  static const String reservationBus = '/reservation/bus';
  static const String reservationBusRecherche = '/reservation/bus/recherche';
  static const String reservationBusListe = '/reservation/bus/liste';
  static const String reservationBusReservation = '/reservation/bus/reservation';
  static const String reservationTaxi = '/reservation/taxi';
  static const String reservationTaxiCommande = '/reservation/taxi/commande';
  static const String reservationTaxiTrajets = '/reservation/taxi/trajets';
  static const String reservationColis = '/reservation/colis';
  static const String reservationColisEnvoi = '/reservation/colis/envoi';
  static const String reservationColisSuivi = '/reservation/colis/suivi';
  static const String reservationEvent = '/reservation/event';
  static const String reservationRestaurant = '/reservation/restaurant';
  static const String reservationMesReservations = '/reservation/mes-reservations';
  static const String reservationFavoris = '/reservation/favoris';
  static const String reservationProfil = '/reservation/profil';

  static const String jobs = '/jobs';
  static const String jobDashboard = '/jobs/dashboard';
  static const String opportunities = '/opportunities';
  static const String education = '/education';
  static const String trainingHome = '/training';
  static const String learningDashboard = '/training/dashboard';
  static const String admin = '/admin';
  static const String adminMedia = '/admin/media';
  static const String recruiter = '/recruiter';
  static const String events = '/events';
}

class AppRouter {
  static GoRouter create(
    AuthController auth, {
    Listenable? extraRefreshListenable,
  }) {
    return GoRouter(
      initialLocation: AppRoutes.home,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const _FallbackPage(title: 'THIX ID'),
        ),
      ],
      errorBuilder: (context, state) => const _FallbackPage(title: 'Page introuvable'),
      refreshListenable: extraRefreshListenable,
    );
  }
}

class _FallbackPage extends StatelessWidget {
  final String title;

  const _FallbackPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(child: Text('Navigation temporairement simplifiee pour compilation.')),
    );
  }
}

extension GoRouterBackHelpers on BuildContext {
  void popOrGo(String fallbackLocation) {
    if (canPop()) {
      pop();
      return;
    }
    go(fallbackLocation);
  }
}
