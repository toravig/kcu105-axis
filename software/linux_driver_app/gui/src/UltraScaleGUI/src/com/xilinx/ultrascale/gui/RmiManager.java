
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
package com.xilinx.ultrascale.gui;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author xhdpssa
 */

import java.rmi.AccessException;
import java.rmi.AlreadyBoundException;
import java.io.File;
import java.io.IOException;
import java.rmi.registry.LocateRegistry;
import java.rmi.NotBoundException;
import java.rmi.registry.Registry;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;


public class RmiManager {

    private static final String LOCK_OBJECT_NAME = "com.xilinx.ultrascale.gui";

    public void createRmiRegistry() {
        try {
            LocateRegistry.createRegistry(Registry.REGISTRY_PORT);
        } catch (RemoteException e) {
        }
    }

    public boolean isAlreadyRunning() {
        try {
            Registry registry = LocateRegistry.getRegistry();

            try {
                IRmiListener rmiListener = (IRmiListener) registry.lookup(LOCK_OBJECT_NAME);
                boolean isAlreadyRunning = rmiListener.isAlreadyRunning();
                return isAlreadyRunning;
            } catch (AccessException e) {
                return false;
            } catch (NotBoundException e) {
                return false;
            }
        } catch (RemoteException e) {
            return false;
        }
    }

    public void registerApplication() throws AlreadyBoundException {
        try {
            RmiListenerImpl rmiListenerImpl = new RmiListenerImpl();
            IRmiListener rmiListener = (IRmiListener) UnicastRemoteObject.exportObject(rmiListenerImpl, Registry.REGISTRY_PORT);
            Registry registry = LocateRegistry.getRegistry();

            registry.bind(LOCK_OBJECT_NAME, rmiListener);
        } catch (RemoteException e) {
        }
    }
}
