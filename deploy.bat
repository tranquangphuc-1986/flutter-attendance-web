@echo off
echo Đang build Flutter Web...
call flutter build web --release
echo Đang deploy lên Firebase...
call firebase deploy
echo Đang đẩy code lên GitHub...
git add .
git commit -m "Auto update and deploy"
git push
echo XONG! Web đã được cập nhật thành công.
pause