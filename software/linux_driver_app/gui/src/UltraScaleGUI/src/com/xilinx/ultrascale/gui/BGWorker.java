/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.xilinx.ultrascale.gui;

import javax.swing.SwingWorker;

/**
 *
 * @author testadvs
 */
public class BGWorker extends SwingWorker<Void, Void> {

    String scriptCmd;

    BGWorker(String cmd) {
        scriptCmd = cmd;
    }

    BGWorker(String run_receive_vlcsh, MainScreen aThis) {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }



    @Override
    protected Void doInBackground() throws Exception {
        if (Develop.production == 1) {
            int retVal = executeShellScript(scriptCmd);//run_perf_mode
        }
        return null;
    }

    @Override
    public void done() {
        // executed the script
    }

    public static int executeShellScript(String cmd) {
        int exitValue = -10;
        try {
            Runtime runtime = Runtime.getRuntime();
            Process process = runtime.exec(new String[]{"/bin/bash", "-c", cmd});
            exitValue = process.waitFor();

        } catch (Exception e) {
            //jTextArea1.append(e.getMessage());
            e.printStackTrace();
        }
        return exitValue;
    }
}
