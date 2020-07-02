class Film{
  final String name;
  final String upc;
  final String url;

  Film(this.name, this.upc, this.url);

  Film .fromJson(Map<String, dynamic> json)
      : name=json['name'],
        upc=json['upc'],
        url=json['url'];

  Map<String, dynamic> toJson() =>
      {
        'name' : name,
        'ups': upc,
        'url': url,
      };



}