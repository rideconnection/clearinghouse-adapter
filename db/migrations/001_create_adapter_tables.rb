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

class CreateAdapterTables < ActiveRecord::Migration
  def change
    create_table :trip_tickets do |t|
      t.integer :ch_id                  # matching ID on the Clearinghouse
      t.datetime :ch_updated_at         # to track the latest change we have seen
      t.boolean :is_originated          # true if originated by our provider

      # originator may reuse an origin_trip_id with a new appointment_time, this should be a separate trip on the CH
      # track these two fields so when importing trips we can determine if trips should be created or updated
      t.integer :origin_trip_id
      t.datetime :appointment_time

      t.text :ch_data                   # the entire clearinghouse ticket stored as JSON
      t.timestamps
    end

    # associated objects will be stored as JSON in the TripTicket ch_data attribute
    # there is no need at the moment to store them in their own tables -- we don't need to query them
    # or look them up except via their associated trip. one thing that would change this is if there
    # were large numbers of claims per trip and we stopped nesting those in the API trips.
    #create_table :trip_claims
    #create_table :trip_results
    #create_table :trip_ticket_comments
  end
end
