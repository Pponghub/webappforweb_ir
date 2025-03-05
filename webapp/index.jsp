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
<%@include file="configuration.jsp"%>
<%@page pageEncoding="UTF-8"%>
<% /* Author: Andrew C. Oliver (acoliver2@users.sourceforge.net) */ %>
<head>
 <style>
        .center-container {
            display: flex;
            flex-direction: column; 
            justify-content: center; 
            align-items: center;
            height: 100vh; 
        }
        img {
            width: 600px; 
            height: auto;
        }
		.sky-gradient {
	    	background: linear-gradient(to bottom, #87CEEB, #B0E0E6);
	    	width: 70%;
	    	height: auto;
	    	margin-bottom: 20px;
	    	margin-left: 1000px;
	    	margin-right: 1000px;
		}
		
		.search-container {
		  display: flex;
		  justify-content: center;
		  align-items: center;
		  background-color: #f5f5f5;
		  border-radius: 30px;
		  padding: 10px 20px;
		  width: 100%;
		  max-width: 600px;
		  margin: 20px auto;
		  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.1);
		  font-family: 'Noto Sans JP', sans-serif;
		}
		
		.search-input {
		  width: 80%;
		  padding: 10px;
		  border: 2px solid #8e5e5e;
		  border-radius: 20px;
		  font-size: 16px;
		  color: #333;
		  background-color: #fff;
		  box-sizing: border-box;
		  transition: all 0.3s ease;
		  padding-left: 30px;
		  padding-right: 30px;
		  marign-left: 20px;
		  marign-right: 20px;
		}
		
		.search-input:focus {
		  border-color: #e60012; 
		  outline: none;
		}
		
		.search-button {
		  padding: 10px 20px;
		  background-color: #e60012; 
		  color: white;
		  border: none;
		  border-radius: 20px;
		  font-size: 16px;
		  cursor: pointer;
		  transition: background-color 0.3s ease;
		}
		
		.search-button:hover {
		  background-color: #d4000f;
		}
		
		.search-container::before {
		  content: "🌸"; 
		  font-size: 24px;
		  margin-right: 10px;
		}
    </style>
    <script>
       function validateSearchInput() {
           var searchInput = document.getElementById("searchInput").value;
           var regex = /^[A-Za-z0-9\s]*$/;
           
           if (!regex.test(searchInput)) {
               alert("English Only");
               return false; 
           }
           return true;
       }
    </script>
</head>
<center> 
	<div class="center-container">
	<div class="sky-gradient"><img src="img/japan_search.png"></img></div>
	<form name="search" action="results.jsp" method="get" onsubmit="return validateSearchInput()">
			<div class="search-container">
			 	<input name="query" type="text" class="search-input" id="searchInput" required>&nbsp;<button class="search-button">Search</button>
			</div>
		<p>
			<input name="maxresults" size="4" value="10"/>&nbsp;Results Per Page&nbsp;
		</p>
    </form>
    </div>
</center>
