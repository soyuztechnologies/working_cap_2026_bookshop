using {sap.capire.bookshop as my} from '../db/schema';

service AnalyticService @(path:'AnalyticService'){
    @readonly entity BooksAnalytics as projection on my.Books{
      *,
      genre.name as genre,
      author.name as author
    };
}


// The first block focuses on enabling aggregate functions. These annotations are crucial for Fiori 
// tools to properly recognize and support the Analytical List Page (ALP). Without these annotations, 
// Fiori tools may raise error indicating the absence of a suitable entity for ALP.
annotate AnalyticService.BooksAnalytics with @(

  Aggregation.ApplySupported: {
    Transformations: [
      'aggregate',
      'topcount',
      'bottomcount',
      'identity',
      'concat',
      'groupby',
      'filter',
      'expand',
      'search'      
    ],

    GroupableProperties: [
      ID,
      author,
      genre,
      title      
    ],

    AggregatableProperties: [{
      $Type : 'Aggregation.AggregatablePropertyType',
      Property: stock
    }]
  },

  Analytics.AggregatedProperty #totalStock: {
    $Type : 'Analytics.AggregatedPropertyType',
    AggregatableProperty : stock,
    AggregationMethod : 'sum',
    Name : 'totalStock',
    ![@Common.Label]: 'Total stock'
  },
);

// The second block is for displaying a chart in the middle of the ALP. 
// One point that was new to me was the use of DynamicMeasure. With OData V2, you may be familiar
//  with "normal" Measure annotations. However, in the context of OData V4, normal Measure somehow does not work, 
// so you need to use DynamicMeasure, which references the @analytics.AggregatedProparety defined in the first block.

annotate AnalyticService.BooksAnalytics with @(
  UI.Chart: {
    $Type : 'UI.ChartDefinitionType',
    Title: 'Stock',
    ChartType : #Column,
    Dimensions: [
      genre
    ],
    DimensionAttributes: [{
      $Type : 'UI.ChartDimensionAttributeType',
      Dimension: genre,
      Role: #Category
    },{
      $Type : 'UI.ChartDimensionAttributeType',
      Dimension: author,
      Role: #author
    }],
    DynamicMeasures: [
      ![@Analytics.AggregatedProperty#totalStock]
    ],
    MeasureAttributes: [{
      $Type: 'UI.ChartMeasureAttributeType',
      DynamicMeasure: ![@Analytics.AggregatedProperty#totalStock],
      Role: #Axis1
    }]
  },
  UI.PresentationVariant: {
    $Type : 'UI.PresentationVariantType',
    Visualizations : [
        '@UI.Chart',
    ],
  }
);


// presentation variant and value list. The chart annotation block is similar to the one in the second block. 
// However, please note that OData V4 currently only supports bar 
// and line chart types for visual filters, whereas OData V2 also supports donut charts.

annotate AnalyticService.BooksAnalytics with @(
  UI.Chart #genre: {
    $Type : 'UI.ChartDefinitionType',
    ChartType: #Bar,
    Dimensions: [
      genre
    ],
    DynamicMeasures: [
      ![@Analytics.AggregatedProperty#totalStock]
    ]
  },
  UI.PresentationVariant #prevgenre: {
    $Type : 'UI.PresentationVariantType',
    Visualizations : [
        '@UI.Chart#genre',
    ],
  }
){
  genre @Common.ValueList #vlgenre: {
    $Type : 'Common.ValueListType',
    CollectionPath : 'BooksAnalytics',
    Parameters: [{
      $Type : 'Common.ValueListParameterInOut',
      ValueListProperty : 'genre',
      LocalDataProperty: genre
    }],
    PresentationVariantQualifier: 'prevgenre'
  }
}

///The fourth block consists of SelectionFields and LineItem annotations that you may already be familiar with.

annotate AnalyticService.BooksAnalytics with@(
    UI: {
        SelectionFields  : [
            genre,
            author,
            publishedAt
        ],
        LineItem: [
            {  $Type : 'UI.DataField', Value : ID, },
            {  $Type : 'UI.DataField', Value : title, },
            {  $Type : 'UI.DataField', Value : genre, },
            {  $Type : 'UI.DataField', Value : author, },
            {  $Type : 'UI.DataField', Value : stock, }
        ],
    }
);

