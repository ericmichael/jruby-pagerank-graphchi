require 'java'
# Modify this to point to your graphchi jar file
require "../graphchi-java/target/graphchi-java-0.2-jar-with-dependencies.jar"
java_import "java.io.FileInputStream"
java_import "java.util.logging.Logger"
require 'gc'
include GC

# Iteratively computes a pagerank for each vertex by averaging the pageranks
# of in-neighbors pageranks.
# Based on work from: @akyrola
# Written for jRuby by: @ericmichael
class PageRank
    include GC::GraphChiProgram

    @@logger = GC::ChiLogger.getLogger "pagerank"

    class VertexProcessor
        def receiveVertexValue(vertexId, token)
            return token == nil ? 0.0 : java.lang.Float.parseFloat(token)
        end
    end

    class EdgeProcessor
        def receiveEdge(from, to, token)
            return token == nil ? 0.0 : java.lang.Float.parseFloat(token)
        end
    end

    # the update function the value that a vertex should
    # take at each iteration
    def update(vertex, context)
        if context.getIteration == 0
            # Initialize on first iteration
            vertex.setValue(1.0)
        else
            # On other iterations, set my value to be the weighted
            # average of my in-coming neighbors pageranks.
            sum = 0.0
            vertex.numInEdges.times { |i| sum += vertex.inEdge(i).getValue }
            vertex.setValue(0.15 + 0.85 * sum)
        end

        # Write my value (divided by my out-degree) to my out-edges so neighbors can read it. #/
        outValue = vertex.getValue / vertex.numOutEdges
        vertex.numOutEdges().times { |i| vertex.outEdge(i).setValue(outValue) }
    end

    # These are not needed for PageRank but we must define them
    def beginIteration(context) end
    def endIteration(context) end
    def beginInterval(context, interval) end
    def endInterval(context, interval) end
    def beginSubInterval(context, interval) end
    def endSubInterval(context, interval) end

     # Initialize the sharder-program.
     # @param graphName
     # @param numShards
     # @return
    def self.createSharder(graphName, numShards)
        vp = VertexProcessor.new
        ep = EdgeProcessor.new
        fc = GC::DoubleConverter.new
        fc2 = GC::DoubleConverter.new

        return GC::FastSharder.new(graphName, numShards.to_i, vp, ep, fc, fc2)
    end

    def self.run(args)
        baseFilename = args[0]
        nShards = args[1]
        fileType = args.length >= 3 ? args[2] : nil

        # Create shards
        sharder = createSharder(baseFilename, nShards)
        if baseFilename=="pipein"    # Allow piping graph in
            sharder.shard(System.in, fileType)
        else
            if !File.exists?(GC::ChiFilenames.getFilenameIntervals(baseFilename, nShards.to_i))
                sharder.shard(FileInputStream.new(java.io.File.new(baseFilename)), fileType)
            else
                @@logger.info("Found shards -- no need to preprocess")
            end
        end

        # Run GraphChi
        engine = GC::GraphChiEngine.new(baseFilename, nShards.to_i)
        engine.setEdataConverter(GC::DoubleConverter.new)
        engine.setVertexDataConverter(GC::DoubleConverter.new)
        engine.setModifiesInedges(false) # Important optimization

        engine.run(PageRank.new, 4)

        @@logger.info("Ready.")

        # Output results
        i = 1
        trans = engine.getVertexIdTranslate()
        top20 = GC::Toplist.topListFloat(baseFilename, engine.numVertices(), 20)

        top20.each_with_index do |vertexRank, i|
            puts "#{i+1}) #{trans.backward(vertexRank.getVertexId())} = #{vertexRank.getValue()}"
        end
    end
end

# Usage: jruby PageRank.rb graph-name num-shards filetype(edgelist|adjlist)
# For specifying the number of shards, 20-50 million edges/shard is often a good configuration.
PageRank.run(ARGV)
