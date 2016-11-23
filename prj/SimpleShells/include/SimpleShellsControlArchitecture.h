#ifndef SIMPLESHELLSCONTROLARCHITECTURE_H
#define SIMPLESHELLSCONTROLARCHITECTURE_H

#include "RoboroboMain/common.h"
#include "RoboroboMain/roborobo.h"

#include "BehaviorControlArchitectures/BehaviorControlArchitecture.h"
#include "SimpleShells/include/SimpleShellsAgentWorldModel.h"

#include "World/World.h"
#include "Agents/RobotAgent.h"

#include "Utilities/Misc.h"
#include "Utils/Rand.h"

#include <cmath>

class RangeSensor;

class SimpleShellsControlArchitecture : public BehaviorControlArchitecture {
        SimpleShellsAgentWorldModel* _wm;

        int _maxLifetime[2];
	int _age;
        int _hiddenNeuronCount;
        int _parameterCount;
        size_t _tournamentSize; /// << tournamentSize smaller than 2 implies rank-based roulettewheel selection
        
        bool _useMarket; //UseMarket initialized here
        bool _useSpecBonus;
        bool _randomSelection;
	double _task1Premium;
        double _selectionPressure;

        std::vector<double> _response;

        void assignFitness(std::vector<Genome> & genomes);
        void gatherGenomes(std::vector<Genome*> & genePool, int commDistSquared);

        std::vector<Genome*> _nearbyGenomes;

        Genome _activeGenome;

        std::vector<Genome>::const_iterator selectWeighted(std::vector<Genome> & genomes);

	void logStats();

	public:
		SimpleShellsControlArchitecture(RobotAgentWorldModel *__wm);
		~SimpleShellsControlArchitecture();

		void step();

        	void reset();
		/// Opportunity for (famous) last words
                void prepareShutdown();
    
		void updateActuators();
		void updateGenomes();
        	void select();

		Genome* getGenome() {return &_activeGenome;}
};


#endif

