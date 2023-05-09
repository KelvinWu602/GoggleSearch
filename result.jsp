<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="core.SearchEngine"%>
<%@ page import="IRUtilities.Query" %>
<%@ page import="IRUtilities.Entry" %>
<%@ page import="IRUtilities.PageSummary" %>
<%@ page import="IRUtilities.WordProfile" %>


<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.lang.String"     %>
<%@ page import="java.util.Map"        %>
<%@ page import="java.io.IOException"  %>
<%@ page import="java.util.LinkedList" %>

<html>
    <head>
        <title>Goggle Search</title>
        <link rel="stylesheet" href="style/result.css">
    </head>
    <body>    
        <%!
            DecimalFormat df = new DecimalFormat("000.00000");

            public void jspInit(){
                SearchEngine.setup();
            }
        %>
        <% 
            String query = request.getParameter("query");
            String pageIDstr = request.getParameter("pageID");
            Long pageID = null;
            if(pageIDstr!=null){
                pageID = Long.parseLong(pageIDstr.trim());
            }
        %>
        <form class="searchdiv" action="result.jsp" method="get">
            <%
                out.write("<input class=\"searchbox\" type=\"text\" name=\"query\" value=\"" + query.replaceAll("\"","&quot;") + "\">");
            %>
            <input class="searchbtn" type="submit">
        </form>      
        <%
            if(query!=null){
                Query q = SearchEngine.preprocessQuery(query);
                LinkedList<Long> RFwordIDs = null;
                LinkedList<Entry> result = null;
                if(pageID!=null){
                    RFwordIDs = SearchEngine.get5MostFrequentWords(pageID);
                    out.write("<p>Relevance Feedback WordIDs:");
                    for(Long l : RFwordIDs){
                        out.write(l + ", ");
                    }
                    out.write("</p>");
                    result = SearchEngine.relevanceFeedbackSearch(q, 50, RFwordIDs);
                }else{
                    result = SearchEngine.search(q, 50);
                }
                out.write("<p> result length:" + result.size() + "</p>");
                for(Entry e : result) {
                    if(Double.isNaN(e.component)) continue;

                    PageSummary ps = SearchEngine.getPageSummary(e.dimension,e.component);
                    out.write("<div class=\"pagesummary\">");
                    
                        out.write("<div class=\"pageinfo\">");
                            out.write("<pre><p>" + df.format(ps.score)+ "    " + ps.metadata.title + "</p></pre>");
                            out.write("<pre>             <a href=\"" + ps.url + "\">" +  ps.url + "</a></pre>");
                            out.write("<pre><p>             " + ps.metadata.lastModified + " " + ps.metadata.size + "</p></pre>");
                            
                            int i = 0;
                            out.write("<pre><p>             ");
                            for(WordProfile words : ps.keywords){
                                if(i++>5) break;
                                out.write(words.word + " " + words.frequency + "; ");
                            }
                            out.write("</p></pre>");

                            i = 0;
                            out.write("<pre><p>             Parents:</p></pre>");
                            for(String s : ps.parentLinks){
                                if(i++>10) break;
                                out.write("<pre>             <a href=\"" + s + "\">" +  s + "</a></pre>");
                            }
                            
                            i = 0;
                            out.write("<pre><p>             Children:</p></pre>");
                            for(String s : ps.childLinks){
                                if(i++>10) break;
                                out.write("<pre>             <a href=\"" + s + "\">" +  s + "</a></pre>");
                            }
                        out.write("</div>");

                        //relevance feedback button with value = pageID

                        out.write("<div class=\"relevancebtndiv\">");
                            out.write("<form action=\"result.jsp\" method=\"get\">");
                                
                                //when the query is pure phrase, it cannot be passed by this method
                                out.write("<input type=\"hidden\" name=\"query\" value=\"" + query.replaceAll("\"","&quot;") + "\">");
                                out.write("<input type=\"hidden\" name=\"pageID\" value=\"" + e.dimension + "\">");
                                out.write("<input class=\"relevancebtn\" type=\"submit\" value=\"Relevance Feedback\">");
                                out.write("</form>");
                            out.write("</div>");        
                        out.write("</div>");
                }
            }
        %>
       
    </body>
</html>


