@echo off
:: Dong duoi day giup file .bat luon chay dung thu muc chua no
cd /d "%~dp0"

echo 1. Dang build Flutter Web...
call flutter build web --release || (echo Build THAT BAI! & pause & exit)

echo.
echo 2. Dang deploy len Firebase...
:: Them dau --only hosting de tranh loi target neu ban khong dung multi-site
call firebase deploy --only hosting || (echo Deploy Firebase THAT BAI! & pause & exit)

echo.
echo 3. Dang day code len GitHub...
git add .
git commit -m "Auto update and deploy %date% %time%"
git push || (echo Push Github THAT BAI! Kiem tra mang. & pause & exit)

echo.
echo === CHUC MUNG! CAP NHAT THANH CONG ===
pause