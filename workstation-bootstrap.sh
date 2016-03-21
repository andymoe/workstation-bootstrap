#!/usr/bin/env bash

# Another (mac) workstation bootstrap script.
# Copyright (C) 2016  Andrew M Brown

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


wb_install () {
	if (( $# != 2)); then
		echo "Usage: wb_install install_func executable_name"
		exit 1
	fi
	local installation_func=$1
	local executable_name=$2

	if [[ $executable_name ]]; then
		which -s "$executable_name"
	fi

	if [[ $? != 0 ]]; then
		echo "installing ${installation_func#*_}"
		$installation_func
	else
		echo "${installation_func#*_} already installed"
	fi
}

wb_replace_system_version_via_brew () {
	which -s brew
	if [[ $? != 0 ]]; then
		echo "wb_install_via_brew requires Homebrew to be installed"
		exit 1
	fi

	if (( $# != 2)); then
		echo "Usage: wb_install_via_brew install_func homebrew_name"
		exit 1
	fi

	local installation_func=$1
	local homebrew_name=$2

	brew ls | grep "^${homebrew_name}$" >/dev/null
	if [[ $? != 0 ]]; then
		echo "installing ${installation_func#*_}"
		$installation_func
	else
		echo "${installation_func#*_} already installed via Homebrew"
	fi
}

wb_prerequisites () {

	wb_homebrew () {
		# Install Homebrew from the internets. Toootally secure.
		HOMEBREW_INSTALL=https://raw.githubusercontent.com/\
		Homebrew/install/master/install
		ACTIVE_RUBY=$(which ruby)
		$ACTIVE_RUBY -e \ "$(curl -fsSL "$HOMEBREW_INSTALL")"
	}

	wb_bats () {
		# Test framework for Bash scripts
		brew install bats
	}

	wb_nuke_rvm () {
		# Because RVM is basically a bash virus
		# and does not play nice with rbenv
		which -s rvm
		if [[ $? != 0 ]]; then
			echo "RVM not found, yay"
			return 1
		fi

		sed -i '' "/.rvm\/scripts\/rvm/d" "${HOME}/.bash_profile"
		yes 'yes' | rvm implode
	}

	wb_install homebrew brew
	wb_install bats bats
	wb_nuke_rvm
}

wb_editors () {

	wb_sublime3 () {
		brew install caskroom/cask/brew-cask
		brew tap caskroom/versions
		brew  cask install sublime-text3
	}

	wb_macvim  () {
		brew cask install macvim
	}

	wb_install sublime3 subl
	wb_install macvim mvim
}

wb_ruby_tools () {

	wb_rbenv () {
		brew install rbenv
	}

	wb_install rbenv rbenv
}

wb_linting_tools () {
	wb_shellcheck () {
		brew install shellcheck
	}

	wb_install wb_shellcheck shellcheck
}

wb_git_and_tools () {
	wb_git () {
		brew install git
	}

	wb_replace_system_version_via_brew wb_git git
}

#-----------------------------
# Install program groups
#-----------------------------
wb_prerequisites
wb_ruby_tools
wb_editors
wb_linting_tools
wb_git_and_tools

# Lint thyself!
shellcheck "$0"
