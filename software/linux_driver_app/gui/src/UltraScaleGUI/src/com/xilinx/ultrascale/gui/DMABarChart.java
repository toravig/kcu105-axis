
/****************************************************************************
 ****************************************************************************/
/** Copyright (C) 2014-2015 Xilinx, Inc.  All rights reserved.
 ** Permission is hereby granted, free of charge, to any person obtaining
 ** a copy of this software and associated documentation files (the
 ** "Software"), to deal in the Software without restriction, including
 ** without limitation the rights to use, copy, modify, merge, publish,
 ** distribute, sublicense, and/or sell copies of the Software, and to
 ** permit persons to whom the Software is furnished to do so, subject to
 ** the following conditions:
 ** The above copyright notice and this permission notice shall be included
 ** in all copies or substantial portions of the Software.Use of the Software 
 ** is limited solely to applications: (a) running on a Xilinx device, or 
 ** (b) that interact with a Xilinx device through a bus or interconnect.  
 ** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 ** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 ** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 ** NONINFRINGEMENT. IN NO EVENT SHALL XILINX BE LIABLE FOR ANY
 ** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 ** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 ** SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 ** Except as contained in this notice, the name of the Xilinx shall
 ** not be used in advertising or otherwise to promote the sale, use or other
 ** dealings in this Software without prior written authorization from Xilinx
 **/
/*****************************************************************************
*****************************************************************************/
/*****************************************************************************/
/**
 *
 * @file DMABarChart.java 
 *
 * Author: Xilinx, Inc.
 *
 * 2007-2010 (c) Xilinx, Inc. This file is licensed uner the terms of the GNU
 * General Public License version 2.1. This program is licensed "as is" without
 * any warranty of any kind, whether express or implied.
 *
 * MODIFICATION HISTORY:
 *
 * Ver   Date     Changes
 * ----- -------- -------------------------------------------------------
 * 1.0  5/15/12  First release
 *
 *****************************************************************************/

package com.xilinx.ultrascale.gui;

import java.awt.Color;
import java.awt.Font;
import java.awt.GradientPaint;
import java.text.DecimalFormat;
import javax.swing.BorderFactory;
import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.axis.CategoryAxis;
import org.jfree.chart.axis.ValueAxis;
import org.jfree.chart.labels.StandardCategoryToolTipGenerator;
import org.jfree.chart.plot.CategoryPlot;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.renderer.category.BarRenderer;
import org.jfree.chart.title.TextTitle;
import org.jfree.data.category.CategoryDataset;
import org.jfree.data.category.DefaultCategoryDataset;

public class DMABarChart {
    int xMarksLength;
    JFreeChart chart;
    Color bg;
    String title;
    String[] seriesLabels;
    DefaultCategoryDataset dataset;
    int index;
    int mark;
    int reverseMark;
    
    public DMABarChart(String title, Color bg, String[] labels){
        xMarksLength = 5;
        this.bg = bg;
        this.title = title;
        seriesLabels = labels;
        index = 1;
        makeChart();
    }
    
    public ChartPanel getChart(String title){
        ChartPanel chartpanel = new ChartPanel(chart);
        chartpanel.setBorder(BorderFactory.createCompoundBorder(
                        BorderFactory.createTitledBorder(title),
                        BorderFactory.createRaisedBevelBorder()));
        return chartpanel;
    }
    
    private void makeChart(){
        dataset = new DefaultCategoryDataset();
        chart = ChartFactory.createBarChart(
            "",
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
        ttitle.setPaint(Color.WHITE);
        chart.setTitle(ttitle);
                
        CategoryPlot plot = chart.getCategoryPlot();
        BarRenderer renderer = (BarRenderer)plot.getRenderer();
        renderer.setDrawBarOutline(false);
        ValueAxis axis = plot.getRangeAxis();
        axis.setUpperBound(64.0);
        axis.setLowerBound(0.0);
        axis.setTickLabelPaint(new Color(185, 185, 185));
        axis.setLabelPaint(new Color(185, 185, 185));
        
        CategoryAxis caxis = plot.getDomainAxis();
        caxis.setTickLabelPaint(new Color(185, 185, 185));
        caxis.setLabelPaint(new Color(185, 185, 185));
        
        renderer.setItemMargin(0);
        renderer.setSeriesPaint(0, new Color(0x2e, 0x90, 0x18));//(0x17, 0x7b, 0x7c));
        renderer.setSeriesPaint(1, new Color(0x12, 0x45, 0x73));//(0xa2, 0x45, 0x73)
        renderer.setSeriesPaint(3, new Color(0xff, 0x80, 0x40));
        renderer.setSeriesPaint(2, new Color(0x6f, 0x2c, 0x85)); 
        renderer.setSeriesPaint(4, new Color(0xa1, 0x60, 0x98));
        renderer.setBaseToolTipGenerator(new StandardCategoryToolTipGenerator("{0}:{2}", new DecimalFormat("0.000")));
        //renderer.setMaximumBarWidth(0.05);
//        addDummy();
    }
    
    public void updateChart(double val1, double val2, double val3, double val4, double val5){
        String name = "";
        if (mark > 0){
            name = ""+reverseMark;
            dataset.addValue(val1, seriesLabels[0], name);
            dataset.addValue(val2, seriesLabels[1], name);
            dataset.addValue(val3, seriesLabels[2], name);
            dataset.addValue(val4, seriesLabels[3], name);
            dataset.addValue(val5, seriesLabels[4], name);
            mark--;
            reverseMark++;
        }else{
            if (dataset.getColumnCount() == xMarksLength){
                dataset.removeColumn(0);
            }
            name = ""+index;
            dataset.addValue(val1, seriesLabels[0], name);
            dataset.addValue(val2, seriesLabels[1], name);
            dataset.addValue(val3, seriesLabels[2], name); // PCI reads/write
            dataset.addValue(val4, seriesLabels[3], name);
            dataset.addValue(val5, seriesLabels[4], name);
            index++;
        }
    }
    
    private void addDummy(){
        for (int i = 0; i < xMarksLength; ++i){
            String name = ""+index;
            dataset.addValue(-1, seriesLabels[0], name);
            dataset.addValue(-1, seriesLabels[1], name);
            dataset.addValue(-1, seriesLabels[2], name); // PCI reads/write
            dataset.addValue(-1, seriesLabels[3], name);
            dataset.addValue(-1, seriesLabels[4], name);
            index++;
        }
        mark = xMarksLength;
        reverseMark = 1;
    }
    
    public void reset(){
        dataset.clear();
        index = 1;
        addDummy();
    }
}
