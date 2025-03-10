<!--
    Licensed to the Apache Software Foundation (ASF) under one or more
    contributor license agreements.  See the NOTICE file distributed with
    this work for additional information regarding copyright ownership.
    The ASF licenses this file to You under the Apache License, Version 2.0
    the "License"); you may not use this file except in compliance with
    the License.  You may obtain a copy of the License at
 
        http://www.apache.org/licenses/LICENSE-2.0
 
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
 -->
<%@page pageEncoding="UTF-8"%>
<%@ page import = "  javax.servlet.*, javax.servlet.http.*, java.io.*, java.net.URLEncoder, java.net.URLDecoder, java.nio.file.Paths, org.apache.lucene.analysis.Analyzer, org.apache.lucene.analysis.TokenStream, org.apache.lucene.analysis.standard.StandardAnalyzer, org.apache.lucene.analysis.th.ThaiAnalyzer, org.apache.lucene.document.Document, org.apache.lucene.index.DirectoryReader, org.apache.lucene.index.IndexReader, org.apache.lucene.queryparser.classic.QueryParser, org.apache.lucene.queryparser.classic.ParseException, org.apache.lucene.search.IndexSearcher, org.apache.lucene.search.Query, org.apache.lucene.search.ScoreDoc, org.apache.lucene.search.TopDocs, org.apache.lucene.search.highlight.Highlighter, org.apache.lucene.search.highlight.InvalidTokenOffsetsException, org.apache.lucene.search.highlight.QueryScorer, org.apache.lucene.search.highlight.SimpleHTMLFormatter, org.apache.lucene.search.highlight.SimpleFragmenter, org.apache.lucene.store.FSDirectory" %>

<%
/*
        Author: Andrew C. Oliver, SuperLink Software, Inc. (acoliver2@users.sourceforge.net)

        This jsp page is deliberatly written in the horrible java directly embedded 
        in the page style for an easy and concise demonstration of Lucene.
        Due note...if you write pages that look like this...sooner or later
        you'll have a maintenance nightmare.  If you use jsps...use taglibs
        and beans!  That being said, this should be acceptable for a small
        page demonstrating how one uses Lucene in a web app. 

        This is also deliberately overcommented. ;-)

*/
%>
<head>
	<style>
	.table-container {
    background-color: #a0d8ef;
	}
	.japan-table {
    margin-left:10%;
	margin-right:10%; 
    border-collapse: collapse;
    background-color: #fffaf0; 
    font-family: 'Noto Sans JP', sans-serif;
	}
	.japan-pagination {
	    margin-top: 10px;
	    text-align: center;
	    font-size: 16px;
	}
	.japan-pagination a {
	    text-decoration: none;
	    padding: 8px 12px;
	    background-color: #b30000;
	    color: white;
	    border-radius: 5px;
	    margin: 0 5px;
	}
	
	.japan-pagination a:hover {
	    background-color: #8b0000;
	}
	</style>
</head>
<%!
public String escapeHTML(String s) {
  s = s.replaceAll("&", "&amp;");
  s = s.replaceAll("<", "&lt;");
  s = s.replaceAll(">", "&gt;");
  s = s.replaceAll("\"", "&quot;");
  s = s.replaceAll("'", "&apos;");
  return s;
}
%>
<%@include file="header.jsp"%>
<%
        boolean error = false;                  //used to control flow for error messages
        String indexName = indexLocation;       //local copy of the configuration variable
        IndexSearcher searcher = null;          //the searcher used to open/search the index
        Query query = null;                     //the Query created by the QueryParser
        TopDocs hits = null;                    //the search results
        int numTotalHits = 0;                   //the number of search results
        int startindex = 0;                     //the first index displayed on this page
        int maxpage    = 50;                    //the maximum items displayed on this page
        String queryString = null;              //the query entered in the previous page
        String startVal    = null;              //string version of startindex
        String maxresults  = null;              //string version of maxpage
        int thispage = 0;
        String lessurl = "";
        String moreurl = "";					//used for the for/next either maxpage or
                                                //hits.totalHits - startindex - whichever is
                                                //less

        try {
          IndexReader reader = DirectoryReader.open(FSDirectory.open(Paths.get(indexName)));
          searcher = new IndexSearcher(reader);         //create an indexSearcher for our page
                                                        //NOTE: this operation is slow for large
                                                        //indices (much slower than the search itself)
                                                        //so you might want to keep an IndexSearcher 
                                                        //open
                                                        
        } catch (Exception e) {                         //any error that happens is probably due
                                                        //to a permission problem or non-existant
                                                        //or otherwise corrupt index
%>
                <p>ERROR opening the Index - contact sysadmin!</p>
                <p>Error message: <%=escapeHTML(e.getMessage())%></p>   
<%                error = true;                                  //don't do anything up to the footer
        }
%>
<%
       //Analyzer analyzer = new StandardAnalyzer(Version.LUCENE_CURRENT);           //construct our usual analyzer
       Analyzer analyzer = new ThaiAnalyzer();

       if (error == false) {                                           //did we open the index?
                //queryString = URLDecoder.decode(request.getParameter("query"),"UTF-8");           //get the search criteria
                queryString = request.getParameter("query");           //get the search criteria
                startVal    = request.getParameter("startat");         //get the start index
                maxresults  = request.getParameter("maxresults");      //get max results per page
                try {
                        maxpage    = Integer.parseInt(maxresults);    //parse the max results first
                        startindex = Integer.parseInt(startVal);      //then the start index  
                } catch (Exception e) { } //we don't care if something happens we'll just start at 0
                                          //or end at 50
                

                if (queryString == null)
                        throw new ServletException("no query "+       //if you don't have a query then
                                                   "specified");      //you probably played on the 
                                                                      //query string so you get the 
                                                                      //treatment

//                Analyzer analyzer = new ThaiAnalyzer();
                try {
                        QueryParser qp = new QueryParser("contents", analyzer);
                        query = qp.parse(queryString.trim()); //parse the 
                } catch (ParseException e) {                          //query and construct the Query
                                                                      //object
                                                                      //if it's just "operator error"
                                                                      //send them a nice error HTML
                                                                      
%>
                        <p>Error while parsing query: <%=escapeHTML(e.getMessage())%></p>
<%
                        error = true;                                 //don't bother with the rest of
                                                                      //the page
                }
        }
%>
<%
        if (error == false && searcher != null) {                     // if we've had no errors
                                                                      // searcher != null was to handle
                                                                      // a weird compilation bug 
                thispage = maxpage;                                   // default last element to maxpage
                hits = searcher.search(query, maxpage + startindex);  // run the query
                numTotalHits = Math.toIntExact(hits.totalHits.value());
                if (numTotalHits == 0) {                             // if we got no results tell the user
%>
                <p> I'm sorry I couldn't find what you were looking for. </p>
<%
                error = true;                                        // don't bother with the rest of the
                                                                     // page
                }
        }

        if (error == false && searcher != null) {                   
%>
<div class="table-container">
                <table class="japan-table">
<%
                if ((startindex + maxpage) > numTotalHits) {
                        thispage = numTotalHits - startindex;      // set the max index to maxpage or last
                }                                                   // actual search result whichever is less

                /* ---------- modified for text snippet ----------- */
                QueryScorer queryScorer = new QueryScorer(query);
                SimpleHTMLFormatter yellow_highlight = new SimpleHTMLFormatter("<b style='background-color:yellow'>", "</b>");
                Highlighter highlighter = new Highlighter(yellow_highlight, queryScorer);
//                Analyzer analyzer = new ThaiAnalyzer();
                /* ------------------------------------------------ */

                for (int i = startindex; i < (thispage + startindex); i++) {  // for each element
%>

<%
                        Document doc = searcher.storedFields().document(hits.scoreDocs[i].doc);                    //get the next document 
                        String doctitle = doc.get("title");            //get its title
                        String url = doc.get("path");                  //get its path field
                        if (url != null && url.startsWith("../webapps/")) { // strip off ../webapps prefix if present
                                url = url.substring(10);
                        }
                        if ((doctitle == null) || doctitle.equals("")) //use the path if it has no title
                                doctitle = url;
                                                                       //then output!
%>
                <tr>
                        <td><%=i+1%>&nbsp;&nbsp;</td><td><font color="blue"><b><%=doctitle%></b></font></td>
                </tr>
<%
				String prefecture = doc.get("prefecture");
				if (prefecture == null) {
					prefecture = "-";
				}
%>
				<tr><td></td><td><b>Prefecture: <%=prefecture%></b></td></tr>
                <tr>
		        <td></td><td>
                <% /* ---------- modified for text snippet ----------- */
                   //=doc.get("contents")
                   String content = doc.get("contents");
                   TokenStream tokenStream = analyzer.tokenStream("contents", content);
                   highlighter.setTextFragmenter(new SimpleFragmenter(100));
                   try {
                     String fragment = highlighter.getBestFragments(tokenStream, content, 2, "...");
                %>
                <%=fragment%>
                <%
                   } catch (InvalidTokenOffsetsException e) {
                     // TODO Auto-generated catch block
                     e.printStackTrace();
                   }
                   /* ------------------------------------------------ */
                %>
		        </td>
                </tr>
                <tr>
		        <td></td><td><a href=<%="//" + doc.get("url")%> target="_blank" style="color:green;text-decoration: none;"><%=doc.get("url")%></a></td>
                </tr>
                <tr><td>&nbsp;</td><td></td></tr>
<%
                }
%>
<%
	int currentPage = (startindex / maxpage) + 1;
    if (startindex > 0) {  
        lessurl = "results.jsp?query=" + URLEncoder.encode(queryString, "UTF-8") + 
                  "&amp;maxresults=" + maxpage + 
                  "&amp;startat=" + (startindex - maxpage);
    }

    if ((startindex + maxpage) < numTotalHits) { 
        moreurl = "results.jsp?query=" + URLEncoder.encode(queryString, "UTF-8") + 
                  "&amp;maxresults=" + maxpage + 
                  "&amp;startat=" + (startindex + maxpage);
    }
%>
         </table>
</div>
         	<div class="japan-pagination">
	    <% if (!lessurl.isEmpty()) { %>
	        <a href="<%= lessurl %>">&lt;&lt;</a>
	    <% } %>
	
	    <span> Page: <%= currentPage %> </span>
	
	    <% if (!moreurl.isEmpty()) { %>
	        <a href="<%= moreurl %>">&gt;&gt;</a>
	    <% } %>
	</div>
         

<%       }                                    //then include our footer.
         //if (searcher != null)
         //       searcher.close();
%>       
