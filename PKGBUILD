pkgname=jappeos_terminal
pkgver=1.0.15
_tag=dev-v1.0.15
pkgrel=1
pkgdesc="A terminal emulator for JappeOS, built with Flutter."
arch=('x86_64')
url="https://github.com/JappeOS/jappeos_terminal"
license=('GPL-3.0')
depends=('glibc' 'gtk3')
makedepends=('git' 'clang' 'cmake' 'ninja')
source=("$pkgname-$pkgver.tar.gz::https://github.com/JappeOS/jappeos_terminal/archive/refs/tags/$_tag.tar.gz")
sha256sums=('SKIP')

build() {
  cd "$srcdir/$pkgname-$pkgver"
  flutter build linux --release
}

package() {
  cd "$srcdir/$pkgname-$pkgver/build/linux/x64/release/bundle"

  # Install to /opt
  install -dm755 "$pkgdir/opt/$pkgname"
  cp -r * "$pkgdir/opt/$pkgname"

  # Symlink executable to /usr/bin
  install -dm755 "$pkgdir/usr/bin"
  ln -s "/opt/$pkgname/$pkgname" "$pkgdir/usr/bin/$pkgname"

  # Install desktop entry
  install -Dm644 "$srcdir/$pkgname-$pkgver/jappeos-terminal.desktop" \
    "$pkgdir/usr/share/applications/jappeos-terminal.desktop"
}