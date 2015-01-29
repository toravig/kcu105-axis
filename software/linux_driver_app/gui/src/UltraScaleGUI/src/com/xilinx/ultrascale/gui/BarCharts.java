package com.xilinx.ultrascale.gui;

/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
import java.awt.Color;
import java.awt.Font;
import java.awt.GradientPaint;
import java.text.DecimalFormat;
import javax.swing.BorderFactory;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.CategoryAxis;
import org.jfree.chart.axis.NumberTickUnit;
import org.jfree.chart.axis.TickUnit;
import org.jfree.chart.axis.TickUnits;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.labels.StandardCategoryToolTipGenerator;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.chart.renderer.category.LineAndShapeRenderer;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.Range;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;

/**
 *
 * @author saisyam
 */
public class BarCharts {

    JFreeChart chart;
    Color bg;
    String title;
    String[] seriesLabels;
    DefaultCategoryDataset dataset;
    int index;
    int mark;
    int reverseMark;
    int xMarksLength;

    public BarCharts(String title, String type, Color bg, String[] labels) {
        xMarksLength = 8;
        this.bg = bg;
        this.title = title;
        seriesLabels = labels;
        index = 1;
        makeChart(type);

    }

    public ChartPanel getChart(String title) {
        ChartPanel chartpanel = new ChartPanel(chart);
        chartpanel.setRangeZoomable(false);
        chartpanel.setDomainZoomable(false);
        chartpanel.setBorder(BorderFactory.createCompoundBorder(
                BorderFactory.createTitledBorder(title),
                BorderFactory.createRaisedBevelBorder()));
        return chartpanel;
    }

    private void makeChart(String name) {
        dataset = new DefaultCategoryDataset();
//        chart = ChartFactory.createLineChart("", "", name, dataset, PlotOrientation.VERTICAL, true, true, false);
//        chart = ChartFactory.createBarChart("asd", "asd", "asdffa", dataset, PlotOrientation.HORIZONTAL, true, true, false);

        chart = ChartFactory.createBarChart(
                "power",
                "Time Interval",
                "Throughput (Gbps)",
                dataset,
                PlotOrientation.VERTICAL,
                true,
                true,
                false
        );

        chart.setBackgroundPaint(bg);

        TextTitle ttitle = new TextTitle(title, new Font(title, Font.BOLD, 15));
        ttitle.setPaint(Color.BLACK);
        chart.setTitle(ttitle);

        CategoryPlot plot = chart.getCategoryPlot();
//        BarRenderer renderer = (BarRenderer)plot.getRenderer();
        BarRenderer renderer = (BarRenderer) plot.getRenderer();
        renderer.setDrawBarOutline(false);
        ValueAxis axis = plot.getRangeAxis();
        upperBounds(65);

        axis.setTickLabelPaint(new Color(0, 0, 0));//(185, 185, 185)
        
        axis.setLabelPaint(new Color(0, 0, 0));

        CategoryAxis caxis = plot.getDomainAxis();
        caxis.setTickLabelPaint(new Color(0, 0, 0));
        caxis.setLabelPaint(new Color(0, 0, 0));
       

        renderer.setItemMargin(0);
        renderer.setSeriesPaint(0, new Color(0x2e, 0x90, 0x18));//(0x17, 0x7b, 0x7c));
        renderer.setSeriesPaint(1, new Color(0x12, 0x45, 0x73));//(0xa2, 0x45, 0x73)
        renderer.setSeriesPaint(3, new Color(0xff, 0x80, 0x40));
        renderer.setSeriesPaint(2, new Color(0x6f, 0x2c, 0x85));
//        renderer.setBaseToolTipGenerator(new StandardCategoryToolTipGenerator("{0}:{2}", new DecimalFormat("0.000")));
        //renderer.setMaximumBarWidth(0.05);
        addDummy();
    }

    public void upperBounds(int topVal) {
        CategoryPlot plot = chart.getCategoryPlot();
//        BarRenderer renderer = (BarRenderer)plot.getRenderer();
        BarRenderer renderer = (BarRenderer) plot.getRenderer();
        renderer.setDrawBarOutline(false);
        ValueAxis axis = plot.getRangeAxis();
        axis.setUpperBound(topVal);
        axis.setLowerBound(0.0);
        if(topVal == 32){
            TickUnits tu = new TickUnits();
            tu.add(new NumberTickUnit(4));
            axis.setStandardTickUnits(tu);
        }
              
//        axis.setAutoRangeMinimumSize(1.0);
//        axis.setAutoRange(true);
////        axis.setLowerMargin(0);
//        axis.setLowerMargin(0);
//        axis.setUpperMargin(0.40);
//        axis.setAutoRangeMinimumSize(1.0);
//        axis.setDefaultAutoRange(new Range(0, 1000));
    }
    int setAutoRange = 0;

    public void setaRange() {
        CategoryPlot plot = chart.getCategoryPlot();
        ValueAxis axis = plot.getRangeAxis();

//        axis.setUpperBound(1000.0);
//        axis.setLowerBound(0.0);
//        axis.setAutoRangeMinimumSize(1.0);
        axis.setAutoRange(true);
//        axis.setLowerMargin(0);
        axis.setLowerMargin(0);
        axis.setUpperMargin(0.40);
        axis.setAutoRangeMinimumSize(1.0);
        axis.setDefaultAutoRange(new Range(0, 1000));
    }

    public void updateChart(double val1, double val2) {
//        if(setAutoRange == 0){
//            setaRange();
//            setAutoRange = 1;
//        }
        String name = "";
        if (mark > 0) {
            name = "" + reverseMark;
            dataset.addValue(val1, seriesLabels[0], name);
            dataset.addValue(val2, seriesLabels[1], name);
//            dataset.addValue(val3, seriesLabels[2], name);
            mark--;
            reverseMark++;
        } else {
            if (dataset.getColumnCount() == xMarksLength) {
                dataset.removeColumn(0);
            }
            name = "" + index;
            dataset.addValue(val1, seriesLabels[0], name);
            dataset.addValue(val2, seriesLabels[1], name);
//            dataset.addValue(val3, seriesLabels[2], name); // PCI reads/write
            index++;
        }
    }

    private void addDummy() {
        for (int i = 0; i < xMarksLength; ++i) {
            String name = "" + index;
            dataset.addValue(0, seriesLabels[0], name);
            dataset.addValue(0, seriesLabels[1], name);
//            dataset.addValue(0, seriesLabels[2], name); // PCI reads/write
            index++;
        }
        mark = xMarksLength;
        reverseMark = 1;
    }

    public void reset() {
        dataset.clear();
        index = 1;
        addDummy();
    }
}
