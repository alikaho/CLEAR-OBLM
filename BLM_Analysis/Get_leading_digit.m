function y = Get_leading_digit(x)
  % Function gets the leading digit from a number (e.g. for presentation of errors in bracket form)
  s = sprintf('%1.2e\n',abs(x));
  y = s(1:(length(s)/length(x)):end)-48;
end