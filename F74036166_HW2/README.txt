我的程式跑出的output結果和助教給的有些不同。

1.
我覺得既然有syntax error了，那行Stmt的指令就不會執行，
所以就整行都不印出，例如error_case的第六行
c = 52/0;
依照助教的範例輸出會有
<ERROR> The divisor can not be 0 (line 6)
ASSIGN
但是52/0本身是錯的所以assign給c這件事也不成立，
所以我的不會再印出ASSIGN
第九行的
a = 4*G;
同理也不會再印出MUL和ASSIGN

2.
print 我的不會印出雙引號，除非印出內容有打 \" ，依照c-style的print

P.S我的.l檔是用homework1改的，所以當中有些多餘的程式碼還沒時間修掉，造成閱讀不便，抱歉。
