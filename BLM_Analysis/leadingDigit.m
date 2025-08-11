function y = leadingDigit(x)
  s = sprintf('%1.2e\n',abs(x));
  y = s(1:(length(s)/length(x)):end)-48;
end