sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"analyticapp/test/integration/pages/BooksAnalyticsList",
	"analyticapp/test/integration/pages/BooksAnalyticsObjectPage"
], function (JourneyRunner, BooksAnalyticsList, BooksAnalyticsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('analyticapp') + '/test/flp.html#app-preview',
        pages: {
			onTheBooksAnalyticsList: BooksAnalyticsList,
			onTheBooksAnalyticsObjectPage: BooksAnalyticsObjectPage
        },
        async: true
    });

    return runner;
});

