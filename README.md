PageRank on JRuby using GraphChi
================================

### What is PageRank?

"PageRank is a link analysis algorithm, named after Larry Page and used
by the Google web search engine, that assigns a numerical weighting to
each element of a hyperlinked set of documents, such as the World Wide
Web, with the purpose of "measuring" its relative importance within the
set. The algorithm may be applied to any collection of entities with
reciprocal quotations and references." --- *Continued on [Wikipedia -
PageRank](http://en.wikipedia.org/wiki/PageRank).*

PageRank can be used on many graphs to get the relative importance of
nodes. For example, we can apply it to a social graph of Twitter users
by connecting edges going from a user to all the people he/she follows.
Computing PageRank on this graph would give you an idea of the most
important Tweeters in the Graph.

A naive approach without PageRank would merely look at the person with
the most followers. If you compare a celebrity to a spam account, both
might have very high numbers of followers but the celebrity is more
likely to have followers that also have high amount of followers as
well, such as other celebrities. A spam account in general will have low
quality followers such as new mass created spam accounts with low
follower numbers and new twitter users.

*An example on calculating PageRank with this script is given below*
### What is GraphChi?
"[GraphChi](http://graphlab.org/graphchi/) is a spin-off of the
[GraphLab](http://www.graphlab.org) -project from the Carnegie Mellon
University. It is based on research by [Aapo
Kyrola](http://www.cs.cmu.edu/~akyrola/) and his advisors.

GraphChi can run very large graph computations on just a single machine,
by using a novel algorithm for processing the graph from disk (SSD or
hard drive). Programs for GraphChi are written in the vertex-centric
model, proposed by GraphLab and Google's Pregel. GraphChi runs
vertex-centric programs asynchronously (i.e changes written to edges are
immediately visible to subsequent computation), and in parallel.
GraphChi also supports streaming graph updates and removal of edges from
the graph.

The promise of GraphChi is to bring web-scale graph computation, such as
analysis of social networks, available to anyone with a modern laptop.
It saves you from the hassle and costs of working with a distributed
cluster or cloud services." --- *More at [About
GraphChi](http://graphlab.org/graphchi/).*

GraphChi has an implementation in C++ and in Java. This project assumes
you have downloaded the Java version of the GraphChi binaries from their
website.
### Why JRuby?
JRuby is a high performance, stable, and fully threaded implementation
of the Ruby programming language atop of the Java Virtual Machine. Ruby
is famous for being a very beautiful and eloquent language that is
focused on productivity. I ported over Aapo Kyrola's PageRank
Implementation that comes with GraphChi. I believe that this jRuby
implementation hides away a lot of the details of GraphChi which makes
it more accessible to those that want to look at example code and learn
how it works. ---
*Get [JRuby](http://www.jruby.org/).*



Dependencies
-------------------------
* JRuby - [Download](http://jruby.org/)
* GraphChi for Java -
  [Download](https://code.google.com/p/graphchi-java/)
* Some Data! - *[Example Twitter Dataset (1.4 billion
  edges!)](http://bickson.blogspot.com/2012/03/interesting-twitter-dataset.html) May take over an hour to process depending on your machine*

Usage
------------------------

1.  Download an install JRuby
2.  Download and extract GraphChi for Java
3. Modify the third line of `pagerank.rb` to point to the location of
 your `graphchi-java-0.2-jar-with-dependencies.jar`
 
        # Modify this to point to your graphchi jar file
 
        require "../graphchi-java/target/graphchi-java-0.2-jar-with-dependencies.jar"

4. Run the algorithm

        jruby -J-Xmx4096m PageRank.rb [graph_file] [num_of_shards] [edgelist|adjlist]

Options:

<dl>
  <dt>[graph_file]</dt>
  <dd>The path to the input graph</dd>
  <dt>[num_of_shards]</dt>
  <dd>Set this to be around the number of edges in the graph divided by
50 million for large graphs. For small graphs choose 1.</dd>
  <dt>[edgelist|adjlist]</dt>
  <dd>If your input graph is in edge list format use <b>edgelist</b> if
it is in adjacency list format then use <b>adjlist</b></dd>
</dl>

The Example Dataset
------------

Lets try crunching a real graph. Make sure you have downloaded the
Twitter graph linked above. After extracting it you should get a
`twitter_rv.net` file. Assuming it is in the same directory as the
`pagerank.rb` file, crunch the dataset like this.

    jruby -J-Xmx4096m PageRank.rb twitter_rv.net 30 edgelist


You will be shown the top 20 items in the graph with the highest
PageRank value.


