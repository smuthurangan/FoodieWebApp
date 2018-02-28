<%@ page import="java.io.*" %>
<%@ page import="org.jfree.data.category.DefaultCategoryDataset" %>
<%@ page import="org.jfree.chart.plot.PlotOrientation" %>
<%@ page import="org.jfree.chart.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.awt.image.BufferedImage" %>
<%@ page import="org.jfree.chart.axis.NumberAxis" %>
<%@ page import="org.jfree.chart.axis.NumberTickUnit" %>
<%@ page import="org.jfree.chart.plot.CategoryPlot" %>
<%@ page import="org.jfree.chart.axis.ValueAxis" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="org.jfree.data.RangeType" %>
<%@ page import="org.jfree.chart.axis.CategoryAxis" %>
<%LinkedHashMap<String, String> CACHED_PREDS = new LinkedHashMap();%>
<!DOCTYPE html>
<html>
<head>
    <title>Foodie Web App</title>

    <meta name="description" content="">
    <meta name="keywords" content="">
    <meta name="author" content="">

    <!-- Include scripts -->
    <script type="text/javascript" src="http://code.jquery.com/jquery.min.js"></script>
    <link rel="stylesheet" href="//code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <script type="text/javascript" src="js/script.js"></script>
    <script type="text/javascript" src="js/responsivemultimenu.js"></script>

    <!-- Include styles -->
    <link rel="stylesheet" href="css/responsivemultimenu.css" type="text/css"/>
    <link rel="stylesheet" href="css/styles.css" type="text/css"/>

    <!-- Include media queries -->
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no"/>

    <script>
        $(document).ready(function () {
            $('#aboutus').hide();
            $('#formus').show();
            var startDate = new Date(2017, 4 - 1, 23);
            var endDate = new Date(2017, 5 - 1, 30);
            $("#startdate").datepicker({
                inline: true,
                minDate: startDate,
                maxDate: endDate,
                dateFormat: 'yy-mm-dd'
            });
            $("#enddate").datepicker({
                inline: true,
                minDate: startDate,
                maxDate: endDate,
                dateFormat: 'yy-mm-dd'
            });
            $(function () {
                $('#formselection').on('submit', function (e) {
                    var valuestr = $('#selectVal').val();

                    if (valuestr.startsWith("selected")) {
                        alert("Please select some valid entry");
                        return false;
                    }
                });

            });
        });
    </script>
</head>
<body style="background: #2C2B2C;">
<div>
    <div class="rmm style">
        <ul>
            <li>
                <a href="https://public.tableau.com/profile/erik.platt#!/vizhome/FoodieAnalyticsDashboardv2/LocationDashboard?publish=yes">Dashboard</a>
            </li>
            <li>
                <a href="#">Forecast</a>
                <ul>
                    <li><a href="forecast.jsp?by=rest">By Air Restaurant </a></li>
                    <li><a href="forecast.jsp?by=area">By Area</a></li>
                    <li><a href="forecast.jsp?by=genre">By Genre</a></li>
                </ul>
            </li>
            <li>
                <a href="javascript:$('#aboutus').show();$('#formus').hide();">About Us</a>
            </li>
        </ul>


        <%
            String message = (String) request.getParameter("by");
            if (message == null) message = "rest";
            String select = "Select a Restaurant";
            BufferedReader reader = null;
            int count = -1;
            try {
                String fileName = "pred.csv";
                if (message != null && message.equalsIgnoreCase("area")) {
                    fileName = "pred_area.csv";
                    select = "Select an Area";
                }
                if (message != null && message.equalsIgnoreCase("genre")) {
                    fileName = "pred_genre.csv";
                    select = "Select a Genre";
                }
                if (message != null && message.equalsIgnoreCase("rest")) {
                    fileName = "pred.csv";
                    select = "Select a Restaurant";
                }
                InputStream input = Thread.currentThread().getContextClassLoader().getResourceAsStream(fileName);
                reader = new BufferedReader(new InputStreamReader(input));
                String csvLine;
                while ((csvLine = reader.readLine()) != null) {
                    if (count == -1) {
                        count++;
                        continue;
                    }
                    String row = csvLine;
                    String key = row.substring(0, row.indexOf(","));
                    key = key.trim();
                    key = key.replaceAll("\\s+", "-");
                    CACHED_PREDS.put(key, row.substring(row.indexOf(",") + 1, row.length()) + ":" + count);
                    count++;
                }
            } catch (IOException ex) {
                throw new RuntimeException("Error in reading CSV file: " + ex);
            } finally {
                try {
                    reader.close();
                } catch (IOException e) {
                    throw new RuntimeException("Error while closing input stream: " + e);
                }
            }

            List<String> spinnerArray = new ArrayList<String>();
            Iterator iterator = CACHED_PREDS.keySet().iterator();
            String prev = null;
            while (iterator.hasNext()) {
                String val = (String) iterator.next();
                val = val.substring(0, val.lastIndexOf("_"));
                if (prev == null || !prev.equalsIgnoreCase(val))
                    spinnerArray.add(val);
                prev = val;
            }

            String text = request.getParameter("selectVal");
            String start = request.getParameter("startdate");
            String startVal = "Enter a Start Date";
            String end = request.getParameter("enddate");
            String endVal = "Enter a End Date";
            if(start != null) startVal = start;
            if(end != null) endVal = end;

            String imgSrc = null;
            if (text != null && start != null && end != null) {
                List<Integer> pred = new ArrayList<>();
                String index = CACHED_PREDS.get(text + "_" + start);
                index = index.substring(index.indexOf(":") + 1, index.length());
                String endindex = CACHED_PREDS.get(text + "_" + end);
                endindex = endindex.substring(endindex.indexOf(":") + 1, endindex.length());

                List array = new ArrayList(CACHED_PREDS.keySet()).subList(Integer.parseInt(index), Integer.parseInt(endindex) + 1);

                for (int i = 0; i < array.size(); i++) {
                    String o = CACHED_PREDS.get(array.get(i));
                    o = o.substring(0, o.indexOf(":"));
                    pred.add(new Integer((int) Double.parseDouble(o)));
                }

                DefaultCategoryDataset barDataset = new DefaultCategoryDataset();
                for (int i = 0; i < pred.size(); i++) {
                    String value = array.get(i).toString();
                    barDataset.setValue(pred.get(i), "Dates", value.substring(value.lastIndexOf("_") + 1));
                }

                //Create the chart
                JFreeChart chart = ChartFactory.createBarChart(
                        "Visitors Forecast Bar Chart", "Date", "Visitors", barDataset,
                        PlotOrientation.HORIZONTAL, false, true, false);

                CategoryPlot plot = chart.getCategoryPlot();
                CategoryAxis xAxis = plot.getDomainAxis();
                NumberAxis numberAxis = (NumberAxis)plot.getRangeAxis();
                numberAxis.setStandardTickUnits(NumberAxis.createIntegerTickUnits());


                BufferedImage buf = chart.createBufferedImage(600, 400, null);
                byte[] encoded = Base64.getEncoder().encode(ChartUtilities.encodeAsPNG(buf));
                imgSrc = new String(encoded);
            }
        %>

        <form id="formselection" action="forecast.jsp">
            <p>
            <div class="form-style-6">
            <span id="formus">
                <select name="selectVal" id="selectVal">
                    <% if (text == null) { %>
                    <option selected><%=select%>
                    </option>
                    <%
                        for (int i = 0; i < spinnerArray.size(); i++) {
                            String val = spinnerArray.get(i).toString();
                    %>
                    <option value="<%=val %>"><%=val %> <%
                            }
                        %>
                            <% } else { %>
                            <%
                            for (int i = 0; i < spinnerArray.size(); i++) {
                                String val = spinnerArray.get(i).toString();
                                if (text != null && text.equalsIgnoreCase(val)) {
                                %>
                    <option selected><%=val%>
                            <% } else { %>
                    <option value="<%=val%>"><%=val%>
                            <% } %>

                            <% }
                    } %>

                </select>
                <br>
                <input type="text" id="startdate" name="startdate" value="<%=startVal%>">
                <br>
                <input type="text" id="enddate" name="enddate" value="<%=endVal%>">
                <br>
                <input type="hidden" name="by" id="by" value="<%=message%>">
                <input type="submit">
                <% if (text != null && start != null && end != null) { %>
                <img id="ItemPreview" src=""/>
                <script>
                    document.getElementById("ItemPreview").src = "data:image/png;base64,<%=imgSrc%>"
                </script>
                <% } %>

            </span>
        <span id="aboutus" style="font: small Arial, Helvetica, sans-serif;">
            Foodie Analytics is a leading data analytics and consulting firm headquartered in Chicago, IL with 1,200 employees in the Americas. We bring in 15+ years of analytics experience in the hospitality industry, specializing in predictive modeling, business intelligence, mobile and web application development, and project management. Our approach to solve any big data problem begins with a clear understanding of the underlying business need and key management objectives. Our recommendations are based on thorough data analysis, evaluation of different modeling techniques, and latest technology solutions. Foodie Analytics works with some of the top players in the industry in solving mission-critical reporting and analytical needs and achieving high-impact business outcomes.
            <br><br>
            <u>Corporate Headquarters </u><br>
                    401 N. Michigan Ave. <br>
                    Chicago, IL 60611 <br>
                    (847) 671-8000"
        </span>
        </div>
        </form>
    </div>
</div>

</body>
</html>