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