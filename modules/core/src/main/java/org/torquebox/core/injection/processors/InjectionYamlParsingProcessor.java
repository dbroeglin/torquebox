/*
 * Copyright 2008-2013 Red Hat, Inc, and individual contributors.
 * 
 * This is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free
 * Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA, or see the FSF site: http://www.fsf.org.
 */

package org.torquebox.core.injection.processors;

import java.util.Map;

import org.jboss.as.server.deployment.DeploymentUnit;
import org.torquebox.core.injection.InjectionMetaData;
import org.torquebox.core.processors.AbstractSplitYamlParsingProcessor;

public class InjectionYamlParsingProcessor extends AbstractSplitYamlParsingProcessor {

    public InjectionYamlParsingProcessor() {
        setSectionName( "injection" );
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void parse(DeploymentUnit unit, Object data) throws Exception {
        Map<String, Object> injection = (Map<String, Object>) data;
        if (injection != null) {
            InjectionMetaData imd = new InjectionMetaData();
            Boolean enabled = (Boolean) injection.get( "enabled" );
            imd.setEnabled( enabled );
            unit.putAttachment( InjectionMetaData.ATTACHMENT_KEY, imd );
        }

    }

}
