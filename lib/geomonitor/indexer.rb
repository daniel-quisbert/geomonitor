module Geomonitor
  module Indexer
    
    def get_all_document_ids
      begin
        query = query_solr params: {
          q: '*:*',
          fl: 'layer_slug_s',
          rows: 100000
        }
        query['response']['docs'].map { |doc| doc['layer_slug_s'] }
      end
    end

    def find_document(id)
      query = query_solr params: {
        q: "layer_slug_s:#{id}"
      }
      query['response']['docs'].first
    end

    def document_solr_score(id)
      doc = find_document(id)
      return doc['layer_availability_score_f'] unless doc.nil?
    end

    def query_solr(search_params = params || {})
      Geomonitor::SolrConfiguration.solr.get 'select', search_params
    end

    def update(params)
      uuid = find_document(params[:id])['uuid']
      data = [{ uuid: uuid, layer_availability_score_f: { set: params[:score] } }]
      Geomonitor::SolrConfiguration.solr.update params: { commitWithin: 500, overwrite: true },
                                                data: data.to_json, 
                                                headers: { 'Content-Type' => 'application/json' }
    end

    def commit
      Geomonitor::SolrConfiguration.solr.commit
    end
  end
end
