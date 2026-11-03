const _names = <String, String>{
  'USD': 'Dolar Amerika Serikat',
  'EUR': 'Euro',
  'GBP': 'Poundsterling Inggris',
  'JPY': 'Yen Jepang',
  'SGD': 'Dolar Singapura',
  'IDR': 'Rupiah Indonesia',
};

String currencyName(String code) => _names[code] ?? code;