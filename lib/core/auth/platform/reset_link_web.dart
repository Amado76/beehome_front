import 'dart:js_interop';

@JS('beehomeResetToken')
external String? get _token;
@JS('beehomeResetToken')
external set _token(String? token);
@JS('beehomeResetLink')
external bool? get _resetLink;

({bool resetLink, String? token}) consumeResetLink() {
  final String? token = _token;
  _token = null;
  return (resetLink: _resetLink ?? false, token: token);
}
