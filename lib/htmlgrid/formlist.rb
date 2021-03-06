#!/usr/bin/env ruby

#
#	HtmlGrid -- HyperTextMarkupLanguage Framework
#	Copyright (C) 2003 ywesee - intellectual capital connected
# Andreas Schrafl, Benjamin Fay, Hannes Wyss, Markus Huggler
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#	ywesee - intellectual capital connected, Winterthurerstrasse 52, CH-8006 Zuerich, Switzerland
#	htmlgrid@ywesee.com, www.ywesee.com/htmlgrid
#
# FormList -- htmlgrid -- 25.03.2003 -- aschrafl@ywesee.com

require "htmlgrid/list"
require "htmlgrid/form"
require "htmlgrid/value"
require "htmlgrid/button"

module HtmlGrid
  class FormList < List
    include FormMethods
    DEFAULT_CLASS = Value
    EVENT = :new_item
    def compose_footer(matrix)
      @grid.add(submit, *matrix)
      @grid.set_colspan(*matrix)
    end
  end
end
