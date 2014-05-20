#!/bin/bash

#
# The BSD 3-Clause License. http://www.opensource.org/licenses/BSD-3-Clause
#
# This file is part of 'Qt-builds' project.
# Copyright (c) 2013 by Alexpux (alexpux@gmail.com)
# All rights reserved.
#
# Project: Qt-builds ( https://github.com/Alexpux/Qt-builds )
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# - Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# - Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the distribution.
# - Neither the name of the 'Qt-builds' nor the names of its contributors may
#     be used to endorse or promote products derived from this software
#     without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

# **************************************************************************

P=libmariadbclient
P_V=mariadb_client-${LIBMARIADBCLIENT_VERSION}-src
PKG_TYPE=".tar.gz"
PKG_SRC_FILE="${P_V}${PKG_TYPE}"
PKG_URL=(
	"ftp://ftp.osuosl.org/pub/mariadb/client-native-${pkgver}/src/${PKG_SRC_FILE}"
)
PKG_DEPENDS=(cmake openssl sqlite3 zlib)
PKG_USE_CMAKE=yes

src_download() {
	func_download
}

src_unpack() {
	func_uncompress
}

src_patch() {
	local _patches=(
		$P/fix-libnames-mingw.patch
	)
	
	func_apply_patches \
		_patches[@]
}

src_configure() {
	local _conf_flags=(
		-G "MSYS Makefiles"
		-DCMAKE_INSTALL_PREFIX:PATH=${PREFIX_WIN}
		-DCMAKE_BUILD_TYPE=RELEASE
		-DWITH_EXTERNAL_ZLIB=ON
		-DWITH_SQLITE=OFF
		-DWITH_OPENSSL=ON
	)
	local _allconf="${_conf_flags[@]}"
	func_configure "$_allconf"
}

pkg_build() {
	local _make_flags=(
		${MAKE_OPTS}
	)
	local _allmake="${_make_flags[@]}"
	func_make \
		"$_allmake" \
		"building..." \
		"built"
}

pkg_install() {
	local _install_flags=(
		${MAKE_OPTS}
		install
	)
	local _allinstall="${_install_flags[@]}"
	func_make \
		"$_allinstall" \
		"installing..." \
		"installed"
		
	[[ ! -f $BUILD_DIR/$P_V/post-install.marker ]] && {
		cp "${PREFIX}"/lib/{libmariadb,libmysqlclient}.dll.a
		cp "${PREFIX}"/lib/{libmariadb,libmysqlclient_r}.dll.a
		cp "${PREFIX}"/lib/{libmariadbclient,libmysqlclient}.a
		cp "${PREFIX}"/lib/{libmariadbclient,libmysqlclient_r}.a
		touch $BUILD_DIR/$P_V/post-install.marker
	}
}
