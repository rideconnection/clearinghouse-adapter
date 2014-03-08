# Copyright 2013 Ride Connection
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

class ImportedFile < ActiveRecord::Base
  CONNECTION_SPEC = {
    adapter: "sqlite3",
    database: "db/basic_import_processor_#{ENV["ADAPTER_ENV"] || development}.sqlite3",
    pool: 5,
    timeout: 5000
  }
  
  self.establish_connection CONNECTION_SPEC
  
  #string   :file_name
  #integer  :size
  #datetime :modified
  #integer  :rows
  #integer  :row_errors
  #boolean  :error
  #string   :error_msg
  #datetime :created_at
end