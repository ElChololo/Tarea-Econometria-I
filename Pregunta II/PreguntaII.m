classdef PreguntaII
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here

    properties
        base1
        base2
        merged
    end

    methods
        function obj = PreguntaII(base1,base2)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.base1 = readtable(base1);
            obj.base2 = readtable(base2);
            obj.merged=innerjoin(obj.base1,obj.base2);
        end

        function [obs] est_desc=(obj)
            obs = size(obj.merged)(1);
            [prom_leng  prom_cs prom_mat] = [mean(obj.merged(:,"prom_lect8b_rbd")) ...
                                            mean(obj.merged(:,"prom_soc8b_rbd"))...
                                            mean(obj.merged(:,"prom_mate8b_rbd"))]
    end
end