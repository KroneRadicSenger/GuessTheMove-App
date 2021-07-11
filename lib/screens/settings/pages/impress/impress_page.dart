import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';

const impressPageHtmlContents = r"""
      <!DOCTYPE html>
      <html lang="de">
          <head>
              <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
          </head>
          <body>
              <h1>Impressum</h1>
                  
              <h2>Angaben gem&auml;&szlig; &sect; 5 TMG</h2>
              <p>Tobias Senger<br />
              Rotenbergstr. 35<br />
              74392 Freudental</p>
      
              <h2>Kontakt</h2>
              <p>Telefon: 071433974985<br />
              E-Mail: senger.tobias2000@gmail.com</p>
      
              <p>Quelle: <a href="https://www.e-recht24.de">https://www.e-recht24.de</a></p>
          </body>
      </html>
    """;

class ImpressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Html(data: impressPageHtmlContents),
    );
  }
}
