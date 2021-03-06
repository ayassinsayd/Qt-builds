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

P=OpenSceneGraph
P_V=${P}-${OPENSCENEGRAPH_VERSION}
EXT=".zip"
SRC_FILE="${P_V}${EXT}"
URL=http://www.openscenegraph.org/downloads/developer_releases/${SRC_FILE}
DEPENDS=()

src_download() {
	func_download $P_V $EXT $URL
}

src_unpack() {
	func_uncompress $P_V $EXT
}

src_patch() {
	local _patches=(
		#$P/osg-qt-movetothread.patch
		$P/osg-collada-dae-fixes.patch
	)

	func_apply_patches \
		$P_V \
		_patches[@]
}

src_configure() {
	[[ ! -f $BUILD_DIR/$P_V/configure.marker ]] && {
		echo -n "---> configuring..."
		mkdir -p $BUILD_DIR/$P_V
		local _rell=$( func_absolute_to_relative $BUILD_DIR/$P_V $UNPACK_DIR/$P_V )
		pushd $BUILD_DIR/$P_V > /dev/null
		export COLLADA_DIR=$PREFIX
		export USE_COIN=1
		$PREFIX/bin/cmake \
			$_rell \
			-G 'MSYS Makefiles' \
			-DCMAKE_BUILD_TYPE=Release \
			$( [[ $USE_OPENGL_DESKTOP == no ]] \
				&& echo " \
				-DOSG_GL1_AVAILABLE:BOOL=OFF \
				-DOSG_GL2_AVAILABLE:BOOL=OFF \
				-DOSG_GL3_AVAILABLE:BOOL=OFF \
				-DOSG_GLES1_AVAILABLE:BOOL=OFF \
				-DOSG_GLES2_AVAILABLE:BOOL=ON \
				-DOPENGL_INCLUDE_DIR:PATH=${QTDIR}/include/QtANGLE \
				-DOPENGL_LIBRARY:PATH=${QTDIR}/lib/liblibGLESv2.a \
				-DOPENGL_egl_LIBRARY:PATH=${QTDIR}/lib/liblibEGL.a \
				-DOSG_GL_DISPLAYLISTS_AVAILABLE:BOOL=OFF \
				-DOSG_GL_MATRICES_AVAILABLE:BOOL=OFF \
				-DOSG_GL_VERTEX_FUNCS_AVAILABLE:BOOL=OFF \
				-DOSG_GL_VERTEX_ARRAY_FUNCS_AVAILABLE:BOOL=OFF \
				-DOSG_GL_FIXED_FUNCTION_AVAILABLE:BOOL=OFF \
				-DOSG_CPP_EXCEPTIONS_AVAILABLE:BOOL=OFF" \
			) \
			-DCMAKE_INSTALL_PREFIX=$PREFIX \
			-DBUILD_OSG_EXAMPLES:BOOL=ON \
			-DCOLLADA_INCLUDE_DIR=$PREFIX/include/collada-dom2.4 \
			-DCOLLADA_DYNAMIC_LIBRARY=$PREFIX/lib/libcollada-dom2.4-dp.dll.a \
			-DCOLLADA_BOOST_FILESYSTEM_LIBRARY=$PREFIX/lib/libboost_filesystem-mt.dll.a \
			-DCOLLADA_BOOST_SYSTEM_LIBRARY=$PREFIX/lib/libboost_system-mt.dll.a \
			-DGIFLIB_DIR=$PREFIX \
			-DFREETYPE_DIR=$PREFIX \
			> $LOG_DIR/${P_V//\//_}-configure.log 2>&1 || die "Error configure $P_V"
		touch configure.marker
		unset COLLADA_DIR
		unset USE_COIN
		popd > /dev/null
		echo " done"
	} || {
		echo "---> Already configured"
	}
}

pkg_build() {
	local _make_flags=(
		${MAKE_OPTS}
	)
	local _allmake="${_make_flags[@]}"
	func_make \
		${P_V} \
		"/bin/make" \
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
		${P_V} \
		"/bin/make" \
		"$_allinstall" \
		"installing..." \
		"installed"
}
