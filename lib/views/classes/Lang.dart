import 'package:flutter/material.dart';

class Lang {
  final Locale _locale;

  Lang(this._locale);

  static Lang? of(BuildContext context) {
    return Localizations.of<Lang>(context, Lang);
  }

  String get confirmDeleteRecord {
    switch (_locale.languageCode) {
      case 'en':
        return 'Confirm delete record';
      case 'fr':
        return 'Confirmer la suppression de l\'enregistrement';
      default:
        return 'Confirm delete record';
    }
  }

  String get yes {
    switch (_locale.languageCode) {
      case 'en':
        return 'Yes';
      case 'fr':
        return 'Oui';
      
      default:
        return 'Yes';
    }
  }

  String get cancel {
    switch (_locale.languageCode) {
      case 'en':
        return 'Cancel';
      case 'fr':
        return 'Annuler';
      
      default:
        return 'Cancel';
    }
  }

  String get recordDeletedSuccessfully {
    switch (_locale.languageCode) {
      case 'en':
        return 'Record deleted successfully';
      case 'fr':
        return 'Enregistrement supprimé avec succès';
      default:
        return 'Record deleted successfully';
    }
  }

  String get newStation {
    switch (_locale.languageCode) {
      case 'en':
        return 'New Station';
      case 'fr':
        return 'Nouvelle station';
      default:
        return 'New Station';
    }
  }

  String get editStation {
    switch (_locale.languageCode) {
      case 'en':
        return 'Edit Station';
      case 'fr':
        return 'Éditer la station';
      default:
        return 'Edit Station';
    }
  }

  String get stationName {
    switch (_locale.languageCode) {
      case 'en':
        return 'Station Name';
      case 'fr':
        return 'Nom de la station';
      default:
        return 'Station Name';
    }
  }

  String get latitude {
    switch (_locale.languageCode) {
      case 'en':
        return 'Latitude';
      case 'fr':
        return 'Latitude';
      default:
        return 'Latitude';
    }
  }

  String get longitude {
    switch (_locale.languageCode) {
      case 'en':
        return 'Longitude';
      case 'fr':
        return 'Longitude';
      default:
        return 'Longitude';
    }
  }

  String get stationBack {
    switch (_locale.languageCode) {
      case 'en':
        return 'Back to Stations';
      case 'fr':
        return 'Retour aux stations';
      default:
        return 'Back to Stations';
    }
  }

  String get crudDelete {
    switch (_locale.languageCode) {
      case 'en':
        return 'Delete';
      case 'fr':
        return 'Supprimer';
      default:
        return 'Delete';
    }
  }

  String get submit {
    switch (_locale.languageCode) {
      case 'en':
        return 'Submit';
      case 'fr':
        return 'Soumettre';
      
      default:
        return 'Submit';
    }
  }
}