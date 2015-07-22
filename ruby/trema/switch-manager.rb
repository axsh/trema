#
# Copyright (C) 2008-2013 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

require_relative 'daemon'
require_relative 'executables'
require_relative 'network-component'
require_relative 'switch-daemon'

module Trema
  #
  # The controller class of switch_manager
  #
  class SwitchManager < NetworkComponent
    include Trema::Daemon

    singleton_daemon
    command { | sm | sm.__send__ :command }

    #
    # Event forwarding rule
    #
    # @example
    #   switch_manager.rule => { :port_status => "topology manager", :packet_in => "controller", :state_notify => "topology manager" }
    #
    # @return [Hash]
    #
    attr_accessor :rule

    #
    # Do not cleanup the flow table of switches on startup
    #
    # @example
    #   switch_manager.no_flow_cleanup = true
    #
    # @return [Bool]
    #
    attr_accessor :no_flow_cleanup


    #
    # Add a prefix to the switch manager command, with a trailing
    # space if seperation is required
    #
    # @example
    #   switch_manager.command_prefix = "valgrind -q --tool=memcheck --leak-check=yes --trace-children=yes --log-socket=127.0.0.1:12345 "
    #
    # @return [String]
    #
    attr_accessor :command_prefix


    #
    # Creates a switch manager controller
    #
    # @example
    #   rule = { :port_status => "topology manager", :packet_in => "controller", :state_notify => "topology manager", :vendor => "controller" }
    #   switch_manager = Trema::SwitchManager.new( rule )
    #
    # @return [SwitchManager]
    #
    def initialize(rule, port = nil, unix_path = nil)
      @rule = rule
      @port = port
      @unix_path = unix_path
      @no_flow_cleanup = false
      @command_prefix = ""
      SwitchManager.add self
    end

    #
    # Returns the name of switch manager
    #
    # @example
    #   switch_maanger.name => "switch manager"
    #
    # @return [String]
    #
    def name
      'switch manager'
    end


    def command
      "#{ command_prefix }#{ Executables.switch_manager } #{ options.join " " } -- #{ switch_options.join " " }"
    end


    ############################################################################

    private

    ############################################################################


    def options
      opts = [ "--daemonize" ]
      opts << "--port=#{ @port }" if @port and @unix_path == nil
      opts << "--unix=#{ @unix_path }" if @unix_path
      opts
    end

    def switch_options
      opts = SwitchDaemon.new(@rule).options
      opts << '--no-flow-cleanup' if @no_flow_cleanup
      opts
    end
  end
end

### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
