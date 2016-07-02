#-- encoding: UTF-8
#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2015 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

require 'roar/decorator'
require 'roar/json/hal'

module API
  module V3
    module TimeEntry
      class TimeEntryPayloadRepresenter < Roar::Decorator
        include Roar::JSON::HAL
        include Roar::Hypermedia

        class << self
          def create_class(time_entry)
            injector_class = ::API::V3::Utilities::CustomFieldInjector
            injector_class.create_value_representer_for_property_patching(
              time_entry,
              TimeEntryPayloadRepresenter)
          end

          def create(time_entry)
            create_class(time_entry).new(time_entry)
          end
        end

        self.as_strategy = ::API::Utilities::CamelCasingStrategy.new

        def initialize(represented)
          super(represented)
        end

        property :hours,
                 exec_context: :decorator,
                 getter: -> (*) {
                   datetime_formatter.format_duration_from_hours(represented.hours,
                                                                 allow_nil: true)
                 },
                 setter: -> (value, *) {
                   represented.hours = datetime_formatter.parse_duration_to_hours(
                     value,
                     'hours',
                     allow_nil: true)
                 },
                 render_nil: true

        property :comments,
                 exec_context: :decorator,
                 getter: -> (*) {
                   API::Decorators::Formattable.new(represented.comments, object: represented)
                 },
                 setter: -> (value, *) { represented.comments = value['raw'] },
                 render_nil: true

        private

        def datetime_formatter
          API::V3::Utilities::DateTimeFormatter
        end
      end
    end
  end
end