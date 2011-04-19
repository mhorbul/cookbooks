#
# Cookbook Name:: rvm
# Attribute File:: default
#
# Copyright 2011, Paper Cavalier
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default[:rvm][:version] = :stable
default[:rvm][:track_updates] = true
default[:rvm][:usernames] = []

default[:rvm][:rvmc][:rvm_trust_rvmrcs_flag]=0

default[:rvm][:ruby][:versions] = []
default[:rvm][:ruby][:default] = nil
default[:rvm][:ruby][:gems] = %w(bundler isolate rake)

